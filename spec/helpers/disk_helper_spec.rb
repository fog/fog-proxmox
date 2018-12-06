# frozen_string_literal: true

# Copyright 2018 Tristan Robert

# This file is part of Fog::Proxmox.

# Fog::Proxmox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Fog::Proxmox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Fog::Proxmox. If not, see <http://www.gnu.org/licenses/>.

require 'spec_helper'
require 'fog/proxmox/helpers/disk_helper'

    describe Fog::Proxmox::DiskHelper do
            
        let(:scsi0) do 
            { id: 'scsi0', storage: 'local-lvm', size: 1, options: { cache: 'none' }}
        end

        let(:scsi0_image) do 
            { id: 'scsi0', volid: 'local-lvm:vm-100-disk-1', storage: 'local-lvm', size: 1, options: { cache: 'none' }}
        end

        let(:scsi) do 
            { scsi0: 'local-lvm:vm-100-disk-1,size=8G,cache=none'}
        end

        let(:virtio1) do
	    { id: 'virtio1', volid: 'local:108/vm-108-disk-1.qcow2,size=15G' }
	end

	let(:virtio) do
	    { virtio1: 'local:108/vm-108-disk-1.qcow2,size=15G' }
	end

        let(:cdrom_none) do 
            { ide2: 'none,media=cdrom'}
        end

        let(:cdrom_iso) do 
            { ide2: 'local:iso/alpine-virt-3.7.0-x86_64.iso,media=cdrom'}
        end

        describe '#flatten' do
            it "returns creation string" do
                disk = Fog::Proxmox::DiskHelper.flatten(scsi0)
                assert_equal({ scsi0: 'local-lvm:1,cache=none' }, disk)
            end
            it "returns image string" do
                disk = Fog::Proxmox::DiskHelper.flatten(scsi0_image)
                assert_equal({ scsi0: 'local-lvm:vm-100-disk-1,size=1,cache=none' }, disk)
            end
        end

        describe '#extract_controller' do
            it "returns virtio controller" do
                controller = Fog::Proxmox::DiskHelper.extract_controller(virtio1[:id])
                assert_equal('virtio', controller)
            end
            it "returns scsi controller" do
                controller = Fog::Proxmox::DiskHelper.extract_controller(scsi0[:id])
                assert_equal('scsi', controller)
            end
        end

        describe '#extract_device' do
            it "returns device" do
                device = Fog::Proxmox::DiskHelper.extract_device(scsi0[:id])
                assert_equal(0, device)
            end
        end

        describe '#extract_storage_volid_size' do
            it "returns scsi get storage and volid" do
                storage, volid, size = Fog::Proxmox::DiskHelper.extract_storage_volid_size(scsi[:scsi0])
                assert_equal('local-lvm', storage)
                assert_equal('local-lvm:vm-100-disk-1', volid)
                assert_equal(8589934592, size)
            end
            it "returns virtio get local storage volid and size" do
                storage, volid, size = Fog::Proxmox::DiskHelper.extract_storage_volid_size(virtio[:virtio1])
                assert_equal('local', storage)
                assert_equal('local:108/vm-108-disk-1.qcow2', volid)
                assert_equal(16106127360, size)
            end
            it "returns scsi0 creation storage and volid" do
                disk = Fog::Proxmox::DiskHelper.flatten(scsi0)
                storage, volid, size = Fog::Proxmox::DiskHelper.extract_storage_volid_size(disk[:scsi0])
                assert_equal('local-lvm', storage)
                assert_nil volid
                assert_equal(1, size)
            end
            it "returns cdrom storage and volid none" do
                storage, volid, size = Fog::Proxmox::DiskHelper.extract_storage_volid_size(cdrom_none[:ide2])
                assert_nil storage
                assert_equal('none', volid)
                assert_nil size
            end
            it "returns cdrom storage and volid iso" do
                storage, volid, size = Fog::Proxmox::DiskHelper.extract_storage_volid_size(cdrom_iso[:ide2])
                assert_equal('local', storage)
                assert_equal('local:iso/alpine-virt-3.7.0-x86_64.iso', volid)
                assert_nil size
            end
        end
        describe '#extract_size' do
            it "returns size" do
                size = Fog::Proxmox::DiskHelper.extract_size(scsi[:scsi0])
                assert_equal(8589934592, size)
            end
            it "returns size" do
                size = Fog::Proxmox::DiskHelper.extract_size(virtio[:virtio1])
                assert_equal(16106127360, size)
            end
        end
    end
