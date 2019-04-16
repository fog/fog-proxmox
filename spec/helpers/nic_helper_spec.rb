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
require 'fog/proxmox/helpers/nic_helper'

    describe Fog::Proxmox::NicHelper do
            
        let(:net_vm) do 
            { net0: 'virtio=66:89:C5:59:AA:96,bridge=vmbr0,firewall=1,link_down=1,queues=1,rate=1,tag=1' }
        end

        let(:net_vm_create) do 
            { net0: 'model=virtio,bridge=vmbr0,firewall=1,link_down=1,queues=1,rate=1,tag=1' }
        end

        let(:net_lxc) do 
            { net0: 'eth0=66:89:C5:59:AA:96,bridge=vmbr0,firewall=1,link_down=1,queues=1,rate=1,tag=1' }
        end

        let(:net_lxc_create) do 
            { net0: 'name=eth0,bridge=vmbr0,firewall=1,link_down=1,queues=1,rate=1,tag=1' }
        end

        describe '#extract_model' do
            it "returns model card" do
                model = Fog::Proxmox::NicHelper.extract_nic_id(net_vm[:net0])
                assert_equal 'virtio', model
            end
            it "returns model card creation" do
                model = Fog::Proxmox::NicHelper.extract_nic_id(net_vm_create[:net0])
                assert_equal 'virtio', model
            end
        end

        describe '#extract_name' do
            it "returns lxc name" do
                model = Fog::Proxmox::NicHelper.extract_nic_id(net_lxc[:net0])
                assert_equal 'eth0', model
            end
            it "returns lxc name creation" do
                model = Fog::Proxmox::NicHelper.extract_nic_id(net_lxc_create[:net0])
                assert_equal 'eth0', model
            end
        end

        describe '#extract_mac_address' do
            it "returns vm mac address" do
                mac_address = Fog::Proxmox::NicHelper.extract_mac_address(net_vm[:net0])
                assert_equal '66:89:C5:59:AA:96', mac_address
            end
            it "returns lxc mac address" do
                mac_address = Fog::Proxmox::NicHelper.extract_mac_address(net_lxc[:net0])
                assert_equal '66:89:C5:59:AA:96', mac_address
            end
        end

        describe '#valid?' do
            it "returns true" do
                assert Fog::Proxmox::NicHelper.valid?('net0')
            end
            it "returns false" do
                assert !Fog::Proxmox::NicHelper.valid?('net')
            end
        end

        describe '#collect_nics' do
            it "returns net0" do
                nets = Fog::Proxmox::NicHelper.collect_nics(net_vm.merge({'netout': 'sdfdsgfdsf'}))
                assert nets.has_key?(:net0)
                assert nets.has_value?(net_vm[:net0])
                assert !nets.has_key?('netout')
            end
            it "returns empty" do
                nets = Fog::Proxmox::NicHelper.collect_nics({'netout': 'sdfdsgfdsf'})
                assert nets.empty?
            end
        end
    end