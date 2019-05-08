# frozen_string_literal: true

require "chef"
require "cheffish/merged_config"
require "chef/provisioning/driver"
require "chef/provisioning/machine/windows_machine"
require "chef/provisioning/machine/unix_machine"
require "chef/provisioning/vsphere_driver/clone_spec_builder"
require "chef/provisioning/vsphere_driver/version"
require "chef/provisioning/vsphere_driver/vsphere_helpers"
require "chef/provisioning/vsphere_driver/vsphere_url"
require "chef/provisioning/vsphere_driver/vm_helper"

# Provisions machines in vSphere.
module ChefProvisioningVsphere
  # Inherits the Chef::Provisioning::Driver attirbutes
  class VsphereDriver < Chef::Provisioning::Driver
    include Chef::Mixin::ShellOut

    # Creates the new object via the URL
    #
    # @param [String] driver_url The driver url to connect via.
    # @param [Object] config The config to get to the machine you are creating.
    def self.from_url(driver_url, config)
      VsphereDriver.new(driver_url, config)
    end

    # Create a new Vsphere provisioner.
    # ## Parameters
    # connect_options - hash of options to be passed to RbVmomi::VIM.connect
    #   :host       - required - hostname of the vSphere API server
    #   :port       - optional - port on the vSphere API server (default: 443)
    #   :path        - optional - path on the vSphere API server (default: /sdk)
    #   :use_ssl        - optional - true to use ssl in connection to vSphere API server (default: true)
    #   :insecure   - optional - true to ignore ssl certificate validation errors in connection to vSphere API server (default: false)
    #   :user       - required - user name to use in connection to vSphere API server
    #   :password   - required - password to use in connection to vSphere API server
    def self.canonicalize_url(driver_url, config)
      config = symbolize_keys(config)
      [driver_url || URI::VsphereUrl.from_config(config).to_s, config]
    end

    # Converts the keys from strings to symbols
    #
    # @param [Object] h converts to key:value
    def self.symbolize_keys(h)
      Hash === h ? # rubocop:disable Style/MultilineTernaryOperator
        Hash[
          h.map do |k, v|
            [k.respond_to?(:to_sym) ? k.to_sym : k, symbolize_keys(v)] # rubocop:disable Style/NestedTernaryOperator
          end
        ] : h
    end

    # Converts the keys from strings to symbols
    #
    # @param [Object] hash_like converts to key:value
    def deep_symbolize(hash_like)
      return {} if hash_like.nil?

      r = {}
      hash_like.each do |key, value|
        value = deep_symbolize(value) if value.respond_to?(:values)
        r[key.to_sym] = value
      end
      r
    end

    # Initialize method for this class
    #
    # @param [String] driver_url Location of where the driver needs to connect to.
    # @param [Object] config The complete config of the machine options.
    def initialize(driver_url, config)
      super(driver_url, config)

      uri = URI(driver_url)
      @connect_options = {
        provider: "vsphere",
        host: uri.host,
        port: uri.port,
        use_ssl: uri.use_ssl,
        insecure: uri.insecure,
        path: uri.path,
      }

      if driver_options
        @connect_options[:user] = driver_options[:user]
        @connect_options[:password] = driver_options[:password]
      end
    end

    attr_reader :connect_options

    # Creates a new vm_helper if not already there
    #
    def vm_helper
      @vm_helper ||= ChefProvisioningVsphere::VmHelper.new
    end

    # Acquire a machine, generally by provisioning it.  Returns a Machine
    # object pointing at the machine, allowing useful actions like setup,
    # converge, execute, file and directory.  The Machine object will have a
    # "node" property which must be saved to the server (if it is any
    # different from the original node object).
    #
    # ## Parameters
    # action_handler - the action_handler object that is calling this method; this
    #        is generally a action_handler, but could be anything that can support the
    #        ChefMetal::ActionHandler interface (i.e., in the case of the test
    #        kitchen metal driver for acquiring and destroying VMs; see the base
    #        class for what needs providing).
    # node - node object (deserialized json) representing this machine.  If
    #        the node has a provisioner_options hash in it, these will be used
    #        instead of options provided by the provisioner.  TODO compare and
    #        fail if different?
    #        node will have node['normal']['provisioner_options'] in it with any options.
    #        It is a hash with this format:
    #           -- provisioner_url: vsphere://host:port?ssl=[true|false]&insecure=[true|false]
    #           -- bootstrap_options: hash of options to pass to RbVmomi::VIM::VirtualMachine::CloneTask()
    #                :datacenter
    #                :resource_pool
    #                :cluster
    #                :datastore
    #                :template_name
    #                :template_folder
    #                :vm_folder
    #                :winrm {...} (not yet implemented)
    #                :ssh {...}
    #
    #        Example bootstrap_options for vSphere:
    #          TODO: add other CloneTask params, e.g.: datastore, annotation, resource_pool, ...
    #          'bootstrap_options' => {
    #            'template_name' =>'centos6.small',
    #            'template_folder' =>'Templates',
    #            'vm_folder' => 'MyApp'
    #          }
    #
    #        node['normal']['provisioner_output'] will be populated with information
    #        about the created machine.  For vSphere, it is a hash with this
    #        format:
    #           -- provisioner_url: vsphere:host:port?ssl=[true|false]&insecure=[true|false]
    #           -- vm_folder: name of the vSphere folder containing the VM
    #
    def allocate_machine(action_handler, machine_spec, machine_options)
      machine_options = deep_symbolize(machine_options)
      merge_options! machine_options

      if machine_spec.location
        Chef::Log.warn(
          "Checking to see if #{machine_spec.location} has been created..."
        )
        vm = vm_for(machine_spec)
        if vm
          Chef::Log.warn "returning existing machine"
          return vm
        else
          Chef::Log.warn machine_msg(
            machine_spec.name,
            machine_spec.location["server_id"],
            "no longer exists.  Recreating ..."
          )
        end
      end
      bootstrap_options = machine_options[:bootstrap_options]

      action_handler.report_progress full_description(
        machine_spec, bootstrap_options
      )

      vm = find_or_create_vm(bootstrap_options, machine_spec, action_handler)

      add_machine_spec_location(vm, machine_spec)

      action_handler.performed_action(machine_msg(
                                        machine_spec.name,
                                        vm.config.instanceUuid,
                                        "created"
      ))
      vm
    end

    # Squishes the options to one large hash
    #
    # @param [Object] machine_options taken from Chef provisioning for all the `machine_options`
    def merge_options!(machine_options)
      @config = Cheffish::MergedConfig.new(
        { machine_options: machine_options },
        @config
      )
      @config = deep_symbolize(@config.to_h)
    end

    # Adds machine spec location from other options.
    #
    # @param [Object] machine_spec taken from Chef provisioning for all the `machine_spec`.
    # @param [Object] vm taken from Chef provisioning for all the vm state.
    def add_machine_spec_location(vm, machine_spec)
      machine_spec.location = {
        "driver_url" => driver_url,
        "driver_version" => VERSION,
        "server_id" => vm.config.instanceUuid,
        "is_windows" => is_windows?(vm),
        "allocated_at" => Time.now.utc.to_s,
        "ipaddress" => vm.guest.ipAddress,
      }
    end

    # Verify if machine is there or create it.
    #
    # @param [Object] bootstrap_options taken from Chef provisioning for all the bootstrap options.
    # @param [Object] machine_spec taken from Chef provisioning for all the `machine_spec`.
    # @param [Object] action_handler taken from Chef provisioning for TODO.
    def find_or_create_vm(bootstrap_options, machine_spec, action_handler)
      vm = vsphere_helper.find_vm(
        bootstrap_options[:vm_folder],
        machine_spec.name
      )
      if vm
        Chef::Log.info machine_msg(
          machine_spec.name,
          vm.config.instanceUuid,
          "already created"
        )
      else
        vm = clone_vm(
          action_handler,
          bootstrap_options,
          machine_spec
        )
      end
      vm
    end

    # Creates a full description of the machine.
    #
    # @param [Object] bootstrap_options taken from Chef provisioning for all the bootstrap options.
    # @param [Object] machine_spec taken from Chef provisioning for all the `machine_spec`.
    def full_description(machine_spec, bootstrap_options)
      description = ["creating machine #{machine_spec.name} on #{driver_url}"]
      bootstrap_options.to_hash.each_pair do |key, value|
        if value.is_a?(Hash)
          temp_value = value.clone
          temp_value[:password] = "*********" if value.key?(:password)
        else
          temp_value = value
        end
        description << "  #{key}: #{temp_value.inspect}"
      end
      description
    end

    # Creates a string of specific Machine information
    #
    # @param [String] name The name of the machine
    # @param [String] id The ID of the machine
    # @param [Object] action TODO
    # @return [String] "Machine - ACTION - NAME (UUID on URL)"
    def machine_msg(name, id, action)
      "Machine - #{action} - #{name} (#{id} on #{driver_url})"
    end

    # Sets the machine to ready state. (Creates the machine but does not bootstrap Chef into it.)
    #
    # @param [Object] action_handler TODO
    # @param [Object] machine_options taken from Chef provisioning for all the bootstrap options.
    # @param [Object] machine_spec taken from Chef provisioning for all the `machine_spec`.
    def ready_machine(action_handler, machine_spec, machine_options)
      machine_options = deep_symbolize(machine_options)
      merge_options! machine_options

      vm = start_machine(action_handler, machine_spec, machine_options)
      if vm.nil?
        raise "Machine #{machine_spec.name} does not have a server "\
        "associated with it, or server does not exist."
      end

      bootstrap_options = machine_options[:bootstrap_options]

      transport_respond?(
        machine_options,
        vm,
        action_handler,
        machine_spec
      )

      machine = machine_for(machine_spec, machine_options)

      setup_extra_nics(action_handler, bootstrap_options, vm, machine, machine_spec)

      if has_static_ip(bootstrap_options) && !is_windows?(vm)
        setup_ubuntu_dns(machine, bootstrap_options, machine_spec)
      end

      ## Check if true available after added nic
      vm_helper.open_port?(machine_spec.location["ipaddress"], vm_helper.port) unless machine_spec.location["ipaddress"].nil?
      machine
    end

    # Creates new NICs for the machine
    #
    # @param [Object] action_handler TODO
    # @param [Object] bootstrap_options taken from Chef provisioning for all the bootstrap options.
    # @param [Object] vm The VM object.
    # @param [Object] machine The machine object.
    def setup_extra_nics(action_handler, bootstrap_options, vm, machine, machine_spec)
      networks = bootstrap_options[:network_name]
      networks = [networks] if networks.is_a?(String)
      return if networks.nil? || networks.count < 2

      new_nics = vsphere_helper.add_extra_nic(
        action_handler,
        vm_template_for(bootstrap_options),
        bootstrap_options,
        vm
      )
      if is_windows?(vm) && !new_nics.nil? && vm_helper.open_port?(machine_spec.location["ipaddress"], vm_helper.port)
        new_nics.each do |nic|
          nic_label = nic.device.deviceInfo.label
          machine.execute_always(
            "Disable-Netadapter -Name '#{nic_label}' -Confirm:$false"
          )
        end
      end
    end

    # Is the transport layer ready?
    #
    # @param [Object] action_handler TODO
    # @param [Object] machine_spec taken from Chef provisioning for all the bootstrap options.
    # @param [Object] vm The VM object.
    # @param [Object] machine_options The options required to talk to the VM.
    def transport_respond?(
      machine_options,
      vm,
      action_handler,
      machine_spec
    )
      bootstrap_options = machine_options[:bootstrap_options]

      # this waits for vmware tools to start and the vm to presebnt an ip
      # This may just be the ip of a newly cloned machine
      # Customization below may change this to a valid ip
      wait_until_ready(action_handler, machine_spec, machine_options, vm)

      if !machine_spec.location["ipaddress"] || !has_ip?(machine_spec.location["ipaddress"], vm)
        # find the ip we actually want
        # this will be the static ip to assign
        # or the ip reported back by the vm if using dhcp
        # it *may* be nil if just cloned
        vm_ip = ip_to_bootstrap(bootstrap_options, vm) || vm.guest.ipAddress
        machine_spec.location["ipaddress"] = vm_ip
        transport = nil
        unless vm_ip.nil?
          transport = transport_for(machine_spec, bootstrap_options[:ssh], vm_ip)
        end

        unless !transport.nil? && transport.available? && has_ip?(vm_ip, vm)
          attempt_ip(machine_options, action_handler, vm, machine_spec)
        end
        machine_spec.location["ipaddress"] = vm_ip # vm.guest.ipAddress vmWare ip_address here can be 0.0.0.0
        action_handler.report_progress(
          "IP address obtained: #{machine_spec.location['ipaddress']}"
        )
      end

      wait_for_domain(bootstrap_options, vm, machine_spec, action_handler)

      begin
        wait_for_transport(action_handler, machine_spec, machine_options, vm)
      rescue Timeout::Error
        # Only ever reboot once, and only if it's been less than 10 minutes since we stopped waiting
        if machine_spec.location["started_at"] ||
            remaining_wait_time(machine_spec, machine_options) < -(10 * 60)
          raise
        else
          Chef::Log.warn(machine_msg(
                           machine_spec.name,
                           vm.config.instanceUuid,
                           "started but SSH did not come up.  Rebooting..."
          ))
          restart_server(action_handler, machine_spec, machine_options)
          wait_until_ready(action_handler, machine_spec, machine_options, vm)
          wait_for_transport(action_handler, machine_spec, machine_options, vm)
        end
      end
    end

    # Test out the IP to connect to.
    #
    # @param [Object] action_handler TODO
    # @param [Object] machine_options taken from Chef provisioning for all the bootstrap options.
    # @param [Object] vm The VM object.
    # @param [Object] machine_spec The spec required to talk to the VM.
    def attempt_ip(machine_options, action_handler, vm, machine_spec)
      vm_ip = ip_to_bootstrap(machine_options[:bootstrap_options], vm)
      machine_spec.location["ipaddress"] = vm_ip

      wait_for_ip(vm, machine_options, machine_spec, action_handler)

      unless has_ip?(vm_ip, vm)
        action_handler.report_progress "rebooting..."
        if vm.guest.toolsRunningStatus != "guestToolsRunning"
          msg = "tools have stopped. current power state is "
          msg << vm.runtime.powerState
          msg << " and tools state is "
          msg << vm.guest.toolsRunningStatus
          msg << ". powering up server..."
          action_handler.report_progress(msg)
          vsphere_helper.start_vm(vm)
        else
          restart_server(action_handler, machine_spec, machine_options)
        end
        wait_for_ip(vm, machine_options, machine_spec, action_handler)
      end
    end

    # Wait for the Windows Domain.
    #
    # @param [Object] action_handler TODO
    # @param [Object] bootstrap_options taken from Chef provisioning for all the bootstrap options.
    # @param [Object] vm The VM object.
    # @param [Object] machine_spec The specs to connect to bootstrap machine
    def wait_for_domain(bootstrap_options, vm, machine_spec, action_handler)
      return unless bootstrap_options[:customization_spec]

      domain = if bootstrap_options[:customization_spec].is_a?(String) && is_windows?(vm)
                 spec = vsphere_helper.find_customization_spec(bootstrap_options[:customization_spec])
                 spec.identity.identification.joinDomain
               elsif bootstrap_options[:customization_spec].is_a?(String) && !is_windows?(vm)
                 spec = vsphere_helper.find_customization_spec(bootstrap_options[:customization_spec])
                 spec.identity.domain
               else
                 bootstrap_options[:customization_spec][:domain]
               end

      return unless domain

      if is_windows?(vm) && domain != "local"
        start = Time.now.utc
        trimmed_name = machine_spec.name.byteslice(0, 15)
        expected_name = "#{trimmed_name}.#{domain}"
        action_handler.report_progress(
          "waiting to domain join and be named #{expected_name}"
        )
        until (Time.now.utc - start) > 30 ||
            (vm.guest.hostName == expected_name)
          print "."
          sleep 5
        end
      end
    end

    # Wait for another IP allocation.
    #
    # @param [Object] action_handler TODO
    # @param [Object] vm The VM object.
    # @param [Object] machine_options The machine options required to start the VM.
    # @param [Object] machine_spec The machine spec required to start the VM.
    def wait_for_ip(vm, machine_options, machine_spec, action_handler)
      bootstrap_options = machine_options[:bootstrap_options]
      ip_to_bootstrap(bootstrap_options, vm)
      ready_timeout = machine_options[:ready_timeout] || 300
      msg1 = "waiting up to #{ready_timeout} seconds for customization"
      msg2 = " and find #{machine_spec.location['ipaddress']}" unless machine_spec.location["ipaddress"].nil? # unless vm_ip == vm.guest.ipAddress # RuntimeError: can't modify frozen String
      msg = [msg1, msg2].join
      action_handler.report_progress msg

      vm_ip = ip_to_bootstrap(bootstrap_options, vm) || vm.guest.ipAddress
      machine_spec.location["ipaddress"] = vm_ip
      until transport_for(
        machine_spec,
        machine_options[:bootstrap_options][:ssh],
        vm_ip
      ).available? || remaining_wait_time(machine_spec, machine_options) < 0
        action_handler.report_progress(
          "IP addresses found: #{all_ips_for(vm)}"
        )
        vm_ip = ip_to_bootstrap(bootstrap_options, vm) || vm.guest.ipAddress
        machine_spec.location["ipaddress"] = vm_ip
        if has_ip?(vm_ip, vm)
          transport_for(
            machine_spec,
            machine_options[:bootstrap_options][:ssh],
            vm_ip
          ).available?
        end
        sleep 5
      end
    end

    # Flatten all IPs for a VM
    #
    # @param [Object] vm The VM object.
    def all_ips_for(vm)
      vm.guest.net.map(&:ipAddress).flatten
    end

    # Does the VM have this IP?
    #
    # @param [Object] vm The VM object.
    # @param [String] ip IP to see if it's in the map.
    def has_ip?(ip, vm)
      all_ips_for(vm).include?(ip)
    end

    # Connect to machine without acquiring it
    #
    # @param [Object] machine_options The machine options required to start the VM.
    # @param [Object] machine_spec The machine spec required to start the VM.
    def connect_to_machine(machine_spec, machine_options)
      machine_options = deep_symbolize(machine_options)
      merge_options! machine_options
      machine_for(machine_spec, machine_options)
    end

    # Destroy the Machine
    #
    # @param [Object] machine_options The machine options required to start the VM.
    # @param [Object] machine_spec The machine spec required to start the VM.
    # @param [Object] action_handler TODO
    def destroy_machine(action_handler, machine_spec, machine_options)
      machine_options = deep_symbolize(machine_options)
      merge_options! machine_options
      vm = vm_for(machine_spec)
      if vm
        action_handler.perform_action "Delete VM [#{vm.parent.name}/#{vm.name}]" do
          begin
            vsphere_helper.stop_vm(vm, machine_options[:stop_timeout])
            vm.Destroy_Task.wait_for_completion
          rescue RbVmomi::Fault => fault
            raise fault unless fault.fault.class.wsdl_name == "ManagedObjectNotFound"
          ensure
            machine_spec.location = nil
          end
        end
      end
      strategy = convergence_strategy_for(machine_spec, machine_options)
      strategy.cleanup_convergence(action_handler, machine_spec)
    end

    # Stop the Machine
    #
    # @param [Object] machine_options The machine options required to start the VM.
    # @param [Object] machine_spec The machine spec required to start the VM.
    # @param [Object] action_handler TODO
    def stop_machine(action_handler, machine_spec, machine_options)
      machine_options = deep_symbolize(machine_options)
      merge_options! machine_options
      vm = vm_for(machine_spec)
      if vm
        action_handler.perform_action "Shutdown guest OS and power off VM [#{vm.parent.name}/#{vm.name}]" do
          vsphere_helper.stop_vm(vm, machine_options[:stop_timeout])
        end
      end
    end

    # Start the Machine
    #
    # @param [Object] machine_options The machine options required to start the VM.
    # @param [Object] machine_spec The machine spec required to start the VM.
    # @param [Object] action_handler TODO
    def start_machine(action_handler, machine_spec, machine_options)
      machine_options = deep_symbolize(machine_options)
      merge_options! machine_options
      vm = vm_for(machine_spec)
      if vm
        action_handler.perform_action "Power on VM [#{vm.parent.name}/#{vm.name}]" do
          vsphere_helper.start_vm(vm, machine_options[:bootstrap_options][:ssh][:port])
        end
      end
      vm
    end

    # Restart the Machine
    #
    # @param [Object] machine_options The machine options required to start the VM.
    # @param [Object] machine_spec The machine spec required to start the VM.
    # @param [Object] action_handler TODO
    def restart_server(action_handler, machine_spec, machine_options)
      action_handler.perform_action "restart machine #{machine_spec.name} (#{driver_url})" do
        stop_machine(action_handler, machine_spec, machine_options)
        start_machine(action_handler, machine_spec, machine_options)
        machine_spec.location["started_at"] = Time.now.utc.to_s
      end
    end

    protected

    # Ubuntu requires some...hacking to get DNS to work.
    #
    # @param [Object] bootstrap_options The bootstrap options required to start the VM.
    # @param [Object] _machine_spec The machine spec required to start the VM.
    # @param [Object] machine Machine object to connect to.
    def setup_ubuntu_dns(machine, bootstrap_options, _machine_spec)
      host_lookup = machine.execute_always("host google.com")
      if host_lookup.exitstatus != 0
        if host_lookup.stdout.include?("setlocale: LC_ALL")
          machine.execute_always("locale-gen en_US && update-locale LANG=en_US")
        end
        distro = machine.execute_always("lsb_release -i | sed -e 's/Distributor ID://g'").stdout.strip
        Chef::Log.info "Found distro:#{distro}"
        if distro == "Ubuntu"
          distro_version = machine.execute_always("lsb_release -r | sed -e s/[^0-9.]//g").stdout.strip.to_f
          Chef::Log.info "Found distro version:#{distro_version}"
          if distro_version >= 12.04
            Chef::Log.info "Ubuntu version 12.04 or greater. Need to patch DNS."
            interfaces_file = "/etc/network/interfaces"
            nameservers = bootstrap_options[:customization_spec][:ipsettings][:dnsServerList].join(" ")
            machine.execute_always("if ! cat #{interfaces_file} | grep -q dns-search ; then echo 'dns-search #{bootstrap_options[:customization_spec][:domain]}' >> #{interfaces_file} ; fi")
            machine.execute_always("if ! cat #{interfaces_file} | grep -q dns-nameservers ; then echo 'dns-nameservers #{nameservers}' >> #{interfaces_file} ; fi")
            machine.execute_always("/etc/init.d/networking restart")
            machine.execute_always("apt-get -qq update")
          end
        end
      end
    end

    # Verify static IP.
    #
    # @param [Object] bootstrap_options The bootstrap options required to start the VM.
    def has_static_ip(bootstrap_options)
      if bootstrap_options.key?(:customization_spec)
        bootstrap_options = bootstrap_options[:customization_spec]

        if bootstrap_options.is_a?(String)
          spec = vsphere_helper.find_customization_spec(bootstrap_options)
          return spec.nicSettingMap[0].adapter.ip.is_a?(RbVmomi::VIM::CustomizationFixedIp)
        elsif bootstrap_options.key?(:ipsettings)
          bootstrap_options = bootstrap_options[:ipsettings]
          return bootstrap_options.key?(:ip)
        end
      end
      false
    end

    def remaining_wait_time(machine_spec, machine_options)
      if machine_spec.location["started_at"]
        (machine_options[:start_timeout] || 600) -
          (Time.now.utc - Time.parse(machine_spec.location["started_at"]))
      else
        (machine_options[:create_timeout] || 600) -
          (Time.now.utc - Time.parse(machine_spec.location["allocated_at"]))
      end
    end

    def wait_until_ready(action_handler, machine_spec, machine_options, vm)
      if vm.guest.toolsRunningStatus != "guestToolsRunning"
        if action_handler.should_perform_actions
          action_handler.report_progress "waiting for #{machine_spec.name} (#{vm.config.instanceUuid} on #{driver_url}) to be ready ..."
          invalid_ip_prefix = bootstrap_invalid_ip_prefix(machine_options[:bootstrap_options])
          until remaining_wait_time(machine_spec, machine_options) < 0 || vm_guest_ip?(vm, invalid_ip_prefix)
            print "."
            sleep 5
          end
          action_handler.report_progress "#{machine_spec.name} is now ready"
        end
      end
    end

    def vm_for(machine_spec)
      if machine_spec.location
        vsphere_helper.find_vm_by_id(machine_spec.location["server_id"])
      end
    end

    def clone_vm(action_handler, bootstrap_options, machine_spec)
      machine_name = machine_spec.name
      vm_template = vm_template_for(bootstrap_options)

      spec_builder = CloneSpecBuilder.new(vsphere_helper, action_handler)
      clone_spec = spec_builder.build(vm_template, machine_name, bootstrap_options)
      Chef::Log.debug("Clone spec: #{clone_spec.pretty_inspect}")

      vm_folder = vsphere_helper.find_folder(bootstrap_options[:vm_folder])
      last_progress = 0
      vm_template.CloneVM_Task(
        name: machine_name,
        folder: vm_folder,
        spec: clone_spec
      ).wait_for_progress do |progress|
        if (progress.is_a? Numeric) && (progress / 10).floor != (last_progress / 10).floor
          print "\n#{machine_name} progress: #{progress}%"
          last_progress = progress
        end
      end
      print "\n#{machine_name} done!\n\n"

      vm = vsphere_helper.find_vm(vm_folder, machine_name)
      add_machine_spec_location(vm, machine_spec)

      vsphere_helper.update_main_disk_size_for(vm, bootstrap_options[:main_disk_size_gb])
      vsphere_helper.set_additional_disks_for(vm, bootstrap_options[:datastore], bootstrap_options[:additional_disk_size_gb])
      vsphere_helper.set_initial_iso(vm, bootstrap_options[:initial_iso_file])

      vm
    end

    def vsphere_helper
      @vsphere_helper ||= VsphereHelper.new(
        connect_options,
        config[:machine_options][:bootstrap_options][:datacenter]
      )
    end

    def vm_template_for(bootstrap_options)
      template_folder = bootstrap_options[:template_folder]
      template_name   = bootstrap_options[:template_name]
      vsphere_helper.find_vm(template_folder, template_name) ||
        raise("vSphere VM Template not found [#{template_folder}/#{template_name}]")
    end

    def machine_for(machine_spec, machine_options)
      if machine_spec.location.nil?
        raise "Server for node #{machine_spec.name} has not been created!"
      end

      transport = transport_for(
        machine_spec,
        machine_options[:bootstrap_options][:ssh]
      )
      strategy = convergence_strategy_for(machine_spec, machine_options)

      if machine_spec.location["is_windows"]
        Chef::Provisioning::Machine::WindowsMachine.new(
          machine_spec, transport, strategy
        )
      else
        Chef::Provisioning::Machine::UnixMachine.new(
          machine_spec, transport, strategy
        )
      end
    end

    def is_windows?(vm)
      return false if vm.nil?
      vm.config.guestId.start_with?("win")
    end

    def convergence_strategy_for(machine_spec, machine_options)
      require "chef/provisioning/convergence_strategy/install_msi"
      require "chef/provisioning/convergence_strategy/install_cached"
      require "chef/provisioning/convergence_strategy/no_converge"

      mopts = machine_options[:convergence_options].to_hash.dup
      if mopts[:chef_server]
        mopts[:chef_server] = mopts[:chef_server].to_hash.dup
        mopts[:chef_server][:options] = mopts[:chef_server][:options].to_hash.dup if mopts[:chef_server][:options]
      end

      unless machine_spec.location
        return Chef::Provisioning::ConvergenceStrategy::NoConverge.new(
          mopts, config
        )
      end

      if machine_spec.location["is_windows"]
        Chef::Provisioning::ConvergenceStrategy::InstallMsi.new(
          mopts, config
        )
      elsif machine_options[:cached_installer] == true
        Chef::Provisioning::ConvergenceStrategy::InstallCached.new(
          mops, config
        )
      else
        Chef::Provisioning::ConvergenceStrategy::InstallSh.new(
          mopts, config
        )
      end
    end

    # Wait for the transport connection to happen
    #
    # @param [Object] machine_spec The machine_spec from Chef-Provisioning
    # @param [Object] machine_options Options for remote connections
    # @param [Object] vm The VM object from Chef-Provisioning
    # @param [Object] action_handler taken from Chef provisioning for TODO.
    def wait_for_transport(action_handler, machine_spec, machine_options, vm)
      vm_helper.find_port?(vm, machine_options[:bootstrap_options]) if vm_helper.port.nil?
      transport = transport_for(
        machine_spec,
        machine_options[:bootstrap_options][:ssh]
      )
      unless transport.available?
        if action_handler.should_perform_actions
          action_handler.report_progress "waiting for #{machine_spec.name} (#{vm.config.instanceUuid} on #{driver_url}) to be connectable (transport up and running) ..."

          until remaining_wait_time(machine_spec, machine_options) < 0 || transport.available?
            print "."
            sleep 5
          end

          action_handler.report_progress "#{machine_spec.name} is now connectable"
        end
      end
    end

    # Figure out the transport system to send to the VM
    #
    # @param [Object] machine_spec The machine_spec from Chef-Provisioning
    # @param [Object] remoting_options Options for remote connections
    # @param [String] ip The IP to connect to.
    def transport_for(
      machine_spec,
      remoting_options,
      ip = machine_spec.location["ipaddress"]
    )
      if machine_spec.location["is_windows"]
        create_winrm_transport(ip, remoting_options)
      else
        create_ssh_transport(ip, remoting_options)
      end
    end

    # Create a robust WinRM transport connect, so so many options to make a simple connection
    #
    # @param [String] host The host the VM is connecting to
    # @param [Object] options Options that are required to connect to the host from Chef-Provisioning
    def create_winrm_transport(host, options)
      require "chef/provisioning/transport/winrm"
      winrm_transport = if options[:port] == 5986
                          :ssl
                        else
                          options[:winrm_transport].nil? ? :negotiate : options[:winrm_transport].to_sym
                        end
      port = options[:port] || vm_helper.port
      winrm_options = {
        user: (options[:user]).to_s,
        pass: options[:password],
      }
      if options[:winrm_opts].nil?
        opt = options[:user].include?('\\') ? :disable_sspi : :basic_auth_only
        winrm_options[opt] = true
      else
        winrm_options.merge!(options[:winrm_opts])
      end
      scheme = winrm_transport == :ssl ? "https" : "http"
      endpoint = URI::Generic.build(
        scheme: scheme,
        host: host,
        port: port,
        path: "/wsman"
      ).to_s

      Chef::Provisioning::Transport::WinRM.new(
        endpoint,
        winrm_transport,
        winrm_options,
        config
      )
    end

    # Return a SSH transport for the machine
    #
    # @param [String] host The host the VM is connecting to
    # @param [Object] options Options that are required to connect to the host from Chef-Provisioning
    def create_ssh_transport(host, options)
      require "chef/provisioning/transport/ssh"
      ssh_user = options[:user]
      options = options.each_with_object({}) { |(k, v), memo| memo[k.to_sym] = v; }
      Chef::Provisioning::Transport::SSH.new(
        host,
        ssh_user,
        options.to_hash,
        @config[:machine_options][:sudo] ? { prefix: "sudo " } : {},
        config
      )
    end

    # Find the IP to bootstrap against
    #
    # @param [Object] bootstrap_options The bootstrap options from Chef-Provisioning
    # @param [Object] vm The VM object from Chef-Provisioning
    def ip_to_bootstrap(bootstrap_options, vm)
      start_time = Time.now.utc
      timeout = bootstrap_ip_ready_timeout(bootstrap_options)
      vm_helper.find_port?(vm, bootstrap_options) unless vm_helper.port?

      # First get the IP to be tested
      invalid_ip_prefix = bootstrap_invalid_ip_prefix(bootstrap_options)
      if has_static_ip(bootstrap_options)
        if bootstrap_options[:customization_spec].is_a?(String)
          spec = vsphere_helper.find_customization_spec(bootstrap_options[:customization_spec])
          vm_ip = spec.nicSettingMap[0].adapter.ip.ipAddress
        else
          ## Check if true available
          vm_ip = bootstrap_options[:customization_spec][:ipsettings][:ip]
        end
      elsif use_ipv4_during_bootstrap?(bootstrap_options)
        vm_ip = wait_for_ipv4(bootstrap_ipv4_timeout(bootstrap_options), invalid_ip_prefix, vm)
      else
        until vm_guest_ip?(vm, invalid_ip_prefix) || Time.now.utc - start_time > timeout
          print "."
          sleep 1
        end
        vm_ip = vm.guest.ipAddress
      end

      # Then check that it is reachable
      until Time.now.utc - start_time > timeout
        print "."
        return vm_ip.to_s if vm_helper.open_port?(vm_ip, vm_helper.port, 1)
        sleep 1
      end
      raise "Timed out (#{timeout}s) waiting for ip #{vm_ip} to be connectable"
    end

    # Force IPv4 a bootstrap, default: false
    #
    # @param [Object] bootstrap_options The bootstrap options from Chef-Provisioning
    def use_ipv4_during_bootstrap?(bootstrap_options)
      bootstrap_options.key?(:bootstrap_ipv4) && bootstrap_options[:bootstrap_ipv4] == true
    end

    # Setting a bootstrap ipv4 timeout, default: 30
    #
    # @param [Object] bootstrap_options The bootstrap options from Chef-Provisioning
    def bootstrap_ipv4_timeout(bootstrap_options)
      bootstrap_options.key?(:ipv4_timeout) ? bootstrap_options[:ipv4_timeout].to_i : 30
    end

    # Setting a bootstrap ip timeout, default: 300
    #
    # @param [Object] bootstrap_options The bootstrap options from Chef-Provisioning
    def bootstrap_ip_ready_timeout(bootstrap_options)
      bootstrap_options.key?(:ip_ready_timeout) ? bootstrap_options[:ip_ready_timeout].to_i : 300
    end

    # Get invalid IP prefix which is used to filter out invalid IP of the VM, e.g. IP of the docker nic.
    #
    # @param [Object] bootstrap_options The bootstrap options from Chef-Provisioning
    def bootstrap_invalid_ip_prefix(bootstrap_options)
      bootstrap_options.key?(:invalid_ip_prefix) ? bootstrap_options[:invalid_ip_prefix].to_s : nil
    end

    # Wait for IPv4 address
    #
    # @param [String] timeout_seconds A timeout in seconds, an error will be raised if it is reached
    # @param [String] invalid_ip_prefix The invalid IP prefix
    # @param [Object] vm The VM object from Chef-Provisioning
    def wait_for_ipv4(timeout_seconds, invalid_ip_prefix, vm)
      Chef::Log.info("Waiting #{timeout_seconds}s for ipv4 address.")

      start_time = Time.now.utc
      while (Time.now.utc - start_time) <= timeout_seconds
        # print '.'
        sleep 5
        vm_ips = all_ips_for(vm)
        Chef::Log.info("Found IP address(es): #{vm_ips}")
        next unless vm_guest_ip?(vm, invalid_ip_prefix)
        vm_ips.each do |vm_ip|
          if IPAddr.new(vm_ip).ipv4?
            Chef::Log.info("Found ipv4 address: #{vm_ip}")
            return vm_ip
          end
        end
      end
      raise "Timed out waiting for ipv4 address!"
    end

    # What is the VM guest IP
    #
    # @param [Object] vm The VM object from Chef-Provisioning
    # @param [String] invalid_ip_prefix The invalid IP prefix
    def vm_guest_ip?(vm, invalid_ip_prefix)
      # The docker interface usually has IP like 172.17.x.x, so need to filter it out.
      vm.guest.guestState == "running" && vm.guest.toolsRunningStatus == "guestToolsRunning" &&
        !vm.guest.ipAddress.nil? && !vm.guest.ipAddress.empty? &&
        (!invalid_ip_prefix || !vm.guest.ipAddress.start_with?(invalid_ip_prefix))
    end
  end
end
