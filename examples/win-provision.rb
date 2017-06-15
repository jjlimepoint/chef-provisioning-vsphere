require 'chef/provisioning'
require 'chef/provisioning/vsphere_driver'


#
# This is the main way to connect to vSphere
#
with_vsphere_driver host: '172.16.20.2',
  insecure: true,
  user:     'administrator@vsphere.local',
  password: 'PASSWORD'

#
# These are the machine_options that you need to declare
#
win_bootstrap_options = { :bootstrap_options => {
                            num_cpus: 2,
                            memory_mb: 8096,
                            datacenter: 'Datacenter',
                            resource_pool: 'Cluster',
                            template_folder: 'Windows',
                            template_name: 'windows2012R2',
                            :ssh => {
                              :user => 'Administrator',
                              :password => 'P@ssw0rd!!!',
                              :paranoid => false,
                              :port => "5985"
                            }
                          },
                          ssh_options: { :keepalive => true, :keepalive_interval => 50, :user_known_hosts_file => '/dev/null' },
                          ready_timeout: '30'
                        }

#
# WinRM requires a Chef server (not sure why) so you need to declare it here
#
with_chef_server "https://api.chef.io/organizations/ORG",
                 :client_name => Chef::Config[:node_name],
                 :signing_key_filename => Chef::Config[:client_key]

#
# This is where you can declare the machine
#
machine "testing-windows" do
  machine_options win_bootstrap_options
  tag "haha"
end
