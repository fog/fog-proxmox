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
require 'fog/proxmox/helpers/controller_helper'

    describe Fog::Proxmox::ControllerHelper do
            
        let(:net) do 
            { net0: 'virtio=66:89:C5:59:AA:96,bridge=vmbr0,firewall=1,link_down=1,queues=1,rate=1,tag=1' }
        end
        let(:net_no_options) do 
            { net0: 'virtio=66:89:C5:59:AA:96' }
        end   
        let(:scsi) do 
            { scsi10: 'local-lvm:1,cache=none' }
        end

        describe '#extract' do
            it "returns bridge" do
                bridge = Fog::Proxmox::ControllerHelper.extract('bridge',net[:net0])
                assert_equal 'vmbr0', bridge
            end
            it "returns nil" do
                bridge = Fog::Proxmox::ControllerHelper.extract('bridge',net_no_options[:net0])
                assert !bridge
            end
            it "returns firewall" do
                firewall = Fog::Proxmox::ControllerHelper.extract('firewall',net[:net0])
                assert_equal '1', firewall
            end
            it "returns cache" do
                cache = Fog::Proxmox::ControllerHelper.extract('cache',scsi[:scsi10])
                assert_equal 'none', cache
            end
        end

        describe '#last_index' do
            it "returns -1" do
                last = Fog::Proxmox::ControllerHelper.last_index('net',{})
                assert last == -1
            end
            it "returns 0" do
                last = Fog::Proxmox::ControllerHelper.last_index('net',net)
                assert last == 0
            end
            it "returns 10" do
                last = Fog::Proxmox::ControllerHelper.last_index('scsi',scsi)
                assert last == 10
            end
        end

        describe '#valid?' do
            it "returns true" do
                assert Fog::Proxmox::ControllerHelper.valid?('net','net0')
            end
            it "returns false" do
                assert !Fog::Proxmox::ControllerHelper.valid?('net','sdfdsf')
            end
        end
    end