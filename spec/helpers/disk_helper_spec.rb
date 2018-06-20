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
            { id: 'scsi0', storage: 'local-lvm', size: 1}
        end

        let(:scsi) do 
            { scsi0: 'local-lvm:vm-100-disk-1,size=8G,cache=none'}
        end

        let(:cdrom) do 
            { ide2: 'none,media=cdrom'}
        end

        let(:options) do 
            'cache=none'
        end

        describe '#flatten' do
            it "returns string" do
                disk = Fog::Proxmox::DiskHelper.flatten(scsi0,options)
                assert_equal({ scsi0: 'local-lvm:1,cache=none' }, disk)
            end
        end

        describe '#extract_controller' do
            it "returns controller" do
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
                assert_equal('8G', size)
            end
            it "returns scsi0 creation storage and volid" do
                disk = Fog::Proxmox::DiskHelper.flatten(scsi0,options)
                storage, volid, size = Fog::Proxmox::DiskHelper.extract_storage_volid_size(disk[:scsi0])
                assert_equal('local-lvm', storage)
                assert_nil volid
                assert_equal('1', size)
            end
            it "returns cdrom storage and volid" do
                storage, volid, size = Fog::Proxmox::DiskHelper.extract_storage_volid_size(cdrom[:ide2])
                assert_nil storage
                assert_equal('none', volid)
                assert_nil size
            end
        end

        describe '#extract_size' do
            it "returns size" do
                size = Fog::Proxmox::DiskHelper.extract_size(scsi[:scsi0])
                assert_equal('8G', size)
            end
        end
    end