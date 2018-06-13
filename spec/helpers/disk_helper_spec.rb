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

        let(:options) do 
            'cache=none'
        end

        describe '#flatten' do
            it "returns string" do
                disk = Fog::Proxmox::DiskHelper.flatten(scsi0,options)
                assert_equal({ scsi0: 'local-lvm:1,cache=none' }, disk)
            end
        end
    end