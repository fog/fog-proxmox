# frozen_string_literal: true

# Copyright 2026 ATIX AG

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
require 'fog/proxmox/helpers/efidisk_helper'

describe Fog::Proxmox::EfidiskHelper do
  let(:efidisk0_full) do
    { id: 0, volid: 'local:110/vm-110-disk-0.qcow2,efitype=4m,size=528K,pre-enrolled-keys=1' }
  end

  let(:efidisk0_full_flatten) do
    { id: 0, volid: 'local:110/vm-110-disk-0.qcow2', efitype: '4m', pre_enrolled_keys: '1', size: '528K' }
  end

  let(:efidisk0_min) do
    { id: 0, volid: 'local:110/vm-110-disk-0.qcow2,size=528K' }
  end

  describe '#flatten' do
    it 'returns full efidisk hash' do
      efidisk = Fog::Proxmox::EfidiskHelper.flatten(efidisk0_full_flatten)
      assert_equal(efidisk, { "efidisk0": efidisk0_full[:volid] })
    end
  end

  describe '#extract' do
    it 'returns full efidisk hash' do
      efidisk = Fog::Proxmox::EfidiskHelper.extract(efidisk0_full[:volid])
      assert_equal({
                     id: 0,
                     volid: 'local:110/vm-110-disk-0.qcow2',
                     storage: 'local',
                     efitype: '4m',
                     pre_enrolled_keys: '1',
                     size: '528K'
                   }, efidisk)
    end

    it 'returns full efidisk min' do
      efidisk = Fog::Proxmox::EfidiskHelper.extract(efidisk0_min[:volid])
      assert_equal({
                     id: 0,
                     volid: 'local:110/vm-110-disk-0.qcow2',
                     storage: 'local',
                     efitype: nil,
                     pre_enrolled_keys: nil,
                     size: '528K'
                   }, efidisk)
    end
  end
end
