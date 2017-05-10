# frozen_string_literal: true
require 'chef/provisioning/driver'

module ChefProvisioningVsphere
  # Helps save data in provisioning a machine
  class VmHelper
    attr_accessor :ip, :port

    RESCUE_EXCEPTIONS_ON_ESTABLISH = [
      Errno::EACCES, Errno::EADDRINUSE, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
      Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH, Errno::EPIPE,
      Errno::EPERM, Errno::EFAULT, Errno::EIO, Errno::EHOSTDOWN,
      Net::SSH::Disconnect, Net::SSH::AuthenticationFailed, Net::SSH::ConnectionTimeout,
      Timeout::Error, IPAddr::AddressFamilyError
    ].freeze

    def ip?
      @ip
    end

    def port?
      @port
    end

    def find_port?(vm, options)
      @port = options[:ssh][:port]
      customization_spec = options[:customization_spec]
      if vm.config.guestId.start_with?('win')
        unless customization_spec.nil? && customization_spec.is_a?(Hash)
          winrm_transport =
            customization_spec[:winrm_transport].nil? ? :negotiate : customization_spec[:winrm_transport].to_sym
        end
        winrm_transport ||= :negotiate
        default_win_port = winrm_transport == :ssl ? '5986' : '5985'
        @port = default_win_port if @port.nil?
      elsif port.nil?
        @port = '22'
      end
      true
    end

    def open_port?(host, port, timeout = 5)
      true if ::Socket.tcp(host, port, connect_timeout: timeout)
    rescue *RESCUE_EXCEPTIONS_ON_ESTABLISH
      false
    end
  end
end
