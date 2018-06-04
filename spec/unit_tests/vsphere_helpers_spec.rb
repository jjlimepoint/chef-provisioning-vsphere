require 'chef/provisioning/vsphere_driver'

describe ChefProvisioningVsphere::VsphereHelper do
  let(:subject) do
    connection_opts = {
      host: 'fake.host.com',
      port: 443
    }
    ChefProvisioningVsphere::VsphereHelper.new(connection_opts, 'fake datacenter')
  end
  let(:vm) { vm = double('vm') }
  let(:task) { double('task', wait_for_completion: true) }

  describe '#set_additional_disks_for' do    
    before do
      allow(vm).to receive(:disks).and_return(['root_disk'], ['root_disk', 'first_disk'])
    end

    context 'when datastore is missing' do
      let(:datastore) { nil }
      it 'and no extra disks, nothing is raised' do
        additional_disk_size_gb = nil
        expect { subject.set_additional_disks_for vm, datastore, additional_disk_size_gb }.not_to raise_error
      end

      it 'and has 1 disk, error is raised' do
        additional_disk_size_gb = 1
        expect { subject.set_additional_disks_for vm, datastore, additional_disk_size_gb }.to raise_error(RuntimeError)
      end

      it 'and has multiple disks, error is raised' do
        additional_disk_size_gb = [1, 2]
        expect { subject.set_additional_disks_for vm, datastore, additional_disk_size_gb }.to raise_error(RuntimeError)
      end
    end

    context 'when datastore is present' do
      let(:datastore) { 'some datastore' }
      let(:disk_1) do
        {
            spec: RbVmomi::VIM.VirtualMachineConfigSpec(
            deviceChange: [
              RbVmomi::VIM::VirtualDeviceConfigSpec(
                operation: :add,
                fileOperation: :create,
                device: RbVmomi::VIM.VirtualDisk(
                  key: 1,
                  backing: RbVmomi::VIM.VirtualDiskFlatVer2BackingInfo(
                    fileName: "[#{datastore}]",
                    diskMode: 'persistent',
                    thinProvisioned: true
                  ),
                  capacityInKB: 1 * 1024 * 1024,
                  controllerKey: 1000,
                  unitNumber: 1
                )
              )
            ]
          )
        }
      end

      let(:disk_2) do
        {
            spec: RbVmomi::VIM.VirtualMachineConfigSpec(
            deviceChange: [
              RbVmomi::VIM::VirtualDeviceConfigSpec(
                operation: :add,
                fileOperation: :create,
                device: RbVmomi::VIM.VirtualDisk(
                  key: 2,
                  backing: RbVmomi::VIM.VirtualDiskFlatVer2BackingInfo(
                    fileName: "[#{datastore}]",
                    diskMode: 'persistent',
                    thinProvisioned: true
                  ),
                  capacityInKB: 2 * 1024 * 1024,
                  controllerKey: 1000,
                  unitNumber: 2
                )
              )
            ]
          )
        }
      end

      it 'and no extra disks, nothing is created' do
        additional_disk_size_gb = nil
        expect(vm).not_to receive(:ReconfigVM_Task)
        subject.set_additional_disks_for vm, datastore, additional_disk_size_gb
      end

      it 'and disk is a string, nothing is created' do
        additional_disk_size_gb = ['not a number']
        expect(vm).not_to receive(:ReconfigVM_Task)
        subject.set_additional_disks_for vm, datastore, additional_disk_size_gb
      end

      it 'and has 0 GB, nothing is created' do
        additional_disk_size_gb = [0]
        expect(vm).not_to receive(:ReconfigVM_Task)
        subject.set_additional_disks_for vm, datastore, additional_disk_size_gb
      end

      it 'and has -1 GB, nothing is created' do
        additional_disk_size_gb = [-1]
        expect(vm).not_to receive(:ReconfigVM_Task)
        subject.set_additional_disks_for vm, datastore, additional_disk_size_gb
      end

      it 'and has 1 x 1 GB, create disk' do
        additional_disk_size_gb = 1
        expect(vm).to receive(:ReconfigVM_Task).with(disk_1).and_return(task)
        subject.set_additional_disks_for vm, datastore, additional_disk_size_gb
      end

      it 'and has 2 disks, create 2 disks' do
        additional_disk_size_gb = [1, 2]

        expect(vm).to receive(:ReconfigVM_Task).with(disk_1).and_return(task)
        expect(vm).to receive(:ReconfigVM_Task).with(disk_2).and_return(task)
        subject.set_additional_disks_for vm, datastore, additional_disk_size_gb
      end

      it 'and has 3 disks, including 1 of 0 size, create 2 disks' do
        additional_disk_size_gb = [0, 1, 2]
        expect(vm).to receive(:ReconfigVM_Task).with(disk_1).and_return(task)
        expect(vm).to receive(:ReconfigVM_Task).with(disk_2).and_return(task)

        subject.set_additional_disks_for vm, datastore, additional_disk_size_gb
      end
    end
  end

  describe '#set_initial_iso' do
    let(:cd_rom) do
      double('cd_rom',
        class: RbVmomi::VIM::VirtualCdrom,
        key: 'some key',
        controllerKey: 'some controller key'
      )
    end

    let(:fake_backing) do
      RbVmomi::VIM::VirtualCdromIsoBackingInfo(fileName: 'some_iso.iso')
    end

    let(:iso_spec) do
      { 
        spec: RbVmomi::VIM.VirtualMachineConfigSpec(
          deviceChange: [
            operation: :edit,
            device: RbVmomi::VIM::VirtualCdrom(
              backing: fake_backing,
              key: 'some key',
              controllerKey: 'some controller key',
              connectable: RbVmomi::VIM::VirtualDeviceConnectInfo(
                startConnected: true,
                connected: true,
                allowGuestControl: true
              )
            )
          ]
        )
      }
    end

    before do
      allow(vm).to receive_message_chain(:config, :hardware, :device)
      .and_return([cd_rom])
    end

    it 'does nothing when no iso' do
      expect(vm).not_to receive(:ReconfigVM_Task)
      subject.set_initial_iso vm, nil
    end

    it 'sets initial iso' do
      expect(vm).to receive(:ReconfigVM_Task).with(iso_spec).and_return(task)
      subject.set_initial_iso vm, 'some_iso.iso'
    end
  end
end
