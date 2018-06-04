# frozen_string_literal: true
require 'chef/provisioning/vsphere_driver'

describe ChefProvisioningVsphere::VsphereDriver do
  subject do
    Chef::Provisioning.driver_for_url(
      'vsphere://3.3.3.3:999/crazyapi?use_ssl=false&insecure=true',
      metal_config
    )
  end

  context 'when config does not include the properties included in the url' do
    let(:metal_config) do
      {
        driver_options: {
          user: 'vmapi',
          password: '<password>'
        },
        machine_options: {
          ssh: {
            password: '<password>',
            paranoid: false
          },
          bootstrap_options: {
            datacenter: 'QA1',
            template_name: 'UBUNTU-12-64-TEMPLATE',
            vm_folder: 'DLAB',
            num_cpus: 2,
            memory_mb: 4096,
            resource_pool: 'CLSTR02/DLAB'
          }
        },
        log_level: :debug
      }
    end

    it 'populates the connect options with correct host from the driver url' do
      expect(subject.connect_options[:host]).to eq('3.3.3.3')
    end
    it 'populates the connect options with correct port from the driver url' do
      expect(subject.connect_options[:port]).to eq(999)
    end
    it 'populates the connect options with correct path from the driver url' do
      expect(subject.connect_options[:path]).to eq('/crazyapi')
    end
    it 'populates the connect options with correct use_ssl setting from the driver url' do
      expect(subject.connect_options[:use_ssl]).to eq(false)
    end
    it 'populates the connect options with correct insecure setting from the driver url' do
      expect(subject.connect_options[:insecure]).to eq(true)
    end
  end

  context 'when config keys are stringified' do
    let(:metal_config) do
      {
        'driver_options' => {
          'user' => 'vmapi',
          'password' => '<driver_password>'
        },
        'bootstrap_options' => {
          'machine_options' => {
            'datacenter' => 'QA1',
            'ssh' => {
              'password' => '<machine_password>'
            }
          }
        }
      }
    end

    it 'will symbolize user' do
      expect(subject.connect_options[:user]).to eq('vmapi')
    end
    it 'will symbolize password' do
      expect(subject.connect_options[:password]).to eq('<driver_password>')
    end
    it 'will symbolize ssh password' do
      expect(subject.config[:bootstrap_options][:machine_options][:ssh][:password]).to eq('<machine_password>')
    end
    it 'will symbolize ssh bootstrap options' do
      expect(subject.config[:bootstrap_options][:machine_options][:datacenter]).to eq('QA1')
    end
  end

  describe 'canonicalize_url' do
    context 'when no url is in the config' do
      let(:metal_config) do
        {
          user: 'vmapi',
          password: '<password>',
          host: '4.4.4.4',
          port: 888,
          path: '/yoda',
          use_ssl: false,
          insecure: true
        }
      end

      subject do
        ChefProvisioningVsphere::VsphereDriver.canonicalize_url(
          nil,
          metal_config
        )
      end

      it 'creates the correct driver url from config settings' do
        expect(subject[0]).to eq('vsphere://4.4.4.4:888/yoda?use_ssl=false&insecure=true')
      end
    end

    context 'when no url is in the config and config is missing defaulted values' do
      let(:metal_config) do
        {
          user: 'vmapi',
          password: '<password>',
          host: '4.4.4.4'
        }
      end

      subject do
        ChefProvisioningVsphere::VsphereDriver.canonicalize_url(
          nil,
          metal_config
        )
      end

      it 'creates the correct driver url from default settings' do
        expect(subject[0]).to eq('vsphere://4.4.4.4/sdk?use_ssl=true&insecure=false')
      end
    end
  end

  context "#ip_to_bootstrap" do
    let(:metal_config) { {} }
    let(:vm) { double("vm") }
    let(:vm_helper) do
      double("vm_helper")
    end
    before do
      allow_any_instance_of(Kernel).to receive(:print)
    end

    before do
      allow(subject).to receive(:vm_helper).and_return(vm_helper)

      allow(vm_helper).to receive(:find_port?)
      allow(vm_helper).to receive(:port?)
      allow(vm_helper).to receive(:port).and_return(port)
    end

    let(:port) { 22 }
    let(:bootstrap_conf) { {} }
    
    context "has_static_ip" do
      let(:bootstrap_conf) { { customization_spec: "some spec" } }
      context "customization_spec is named" do
        let(:vsphere_helper) { double("vsphere_helper") }
        let(:fake_spec) { double("fake_spec") }
        let(:fake_adapter) { double("fake_adapter") }
        let(:fake_ip) do
          RbVmomi::VIM::CustomizationFixedIp(
            ipAddress: "1.1.1.1"
          )
        end

        it "return ip address" do
          allow(subject).to receive(:vsphere_helper).and_return(vsphere_helper)
          allow(fake_adapter).to receive_message_chain(:adapter, :ip).and_return(fake_ip)
          allow(fake_spec).to receive(:nicSettingMap).and_return([fake_adapter])
          allow(vsphere_helper).to receive(:find_customization_spec).and_return(fake_spec)
          allow(vm_helper).to receive(:open_port?).with("1.1.1.1", port, 1).and_return(true)

          result = subject.send :ip_to_bootstrap, bootstrap_conf, vm
          expect(result).to eq "1.1.1.1"
        end
      end

      context "customization_spec has an ip address" do
        let(:bootstrap_conf) do
          { 
            customization_spec: {
              ipsettings: {
                ip: "2.2.2.2"
              }
            } 
          }
        end

        it "returns ip address" do
          allow(vm_helper).to receive(:ip?)
          allow(vm_helper).to receive(:open_port?).with("2.2.2.2", port, 1).and_return(true)
          result = subject.send :ip_to_bootstrap, bootstrap_conf, vm
          expect(result).to eq "2.2.2.2"
        end
      end
    end

    context "use_ipv4_during_bootstrap" do
      let(:bootstrap_conf) { { bootstrap_ipv4: true } }

      it "returns ip address" do
        allow(subject).to receive(:wait_for_ipv4).and_return("3.3.3.3")
        allow(vm_helper).to receive(:open_port?).with("3.3.3.3", port, 1).and_return(true)

        result = subject.send :ip_to_bootstrap, bootstrap_conf, vm
        expect(result).to eq "3.3.3.3"
      end
    end

    context "wait until guest tools returns an IP address" do
      it "returns ip address" do
        allow_any_instance_of(Kernel).to receive(:sleep)
        expect(subject).to receive(:vm_guest_ip?).exactly(3).times.and_return(false, false, true)
        allow(vm).to receive_message_chain(:guest, :ipAddress).and_return("4.4.4.4")

        allow(vm_helper).to receive(:open_port?).exactly(1).times.with("4.4.4.4", port, 1).and_return(true)
        result = subject.send :ip_to_bootstrap, bootstrap_conf, vm
        expect(result).to eq "4.4.4.4"
      end
    end
  end
end
