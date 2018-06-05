# frozen_string_literal: true
require "chef/provisioning"
require "chef/provisioning/vsphere_driver"

#
# This is the main way to connect to vSphere
#
with_vsphere_driver host: "172.16.20.2",
                    insecure: true,
                    user:     "administrator@vsphere.local",
                    password: "PASSWORD"

#
# These are the machine_options that you need to declare
#
with_machine_options bootstrap_options: {
  num_cpus: 2,
  memory_mb: 4096,
  datacenter: "Datacenter",
  resource_pool: "Cluster",
  template_folder: "Linux",
  template_name: "ubuntu16",
  ssh: {
    user: "admini",
    password: "PASSWORD",
    paranoid: false,
  },
},
                     sudo: true

#
# This is where you can declare the machine
#
machine "testing-ubuntu" do
  tag "haha"
end
