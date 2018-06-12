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
            
        let(:net) do 
            { net0: 'virtio=66:89:C5:59:AA:96,bridge=vmbr0,firewall=1,link_down=1,queues=1,rate=1,tag=1' }
        end

        describe '#extract_model' do
            it "returns model card" do
                model = Fog::Proxmox::NicHelper.extract_model(net[:net0])
                assert_equal 'virtio', model
            end
        end

        describe '#extract_mac_address' do
            it "returns mac address" do
                mac_address = Fog::Proxmox::NicHelper.extract_mac_address(net[:net0])
                assert_equal '66:89:C5:59:AA:96', mac_address
            end
        end

        describe '#extract' do
            it "returns bridge" do
                bridge = Fog::Proxmox::NicHelper.extract('bridge',net[:net0])
                assert_equal 'vmbr0', bridge
            end
            it "returns firewall" do
                firewall = Fog::Proxmox::NicHelper.extract('firewall',net[:net0])
                assert_equal '1', firewall
            end
        end
    end