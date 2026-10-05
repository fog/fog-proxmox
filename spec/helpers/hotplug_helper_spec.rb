# frozen_string_literal: true

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
require 'fog/proxmox/helpers/hotplug_helper'

describe 'HotplugHelper' do
  describe '.extract' do
    [nil, '', '1', 1].each do |hotplug|
      it "uses enabled default devices for #{hotplug.inspect}" do
        assert_equal({ enabled: true, devices: %w[disk network usb] }, Fog::Proxmox::HotplugHelper.extract(hotplug))
      end
    end

    ['0', 0].each do |hotplug|
      it "disables hotplug for #{hotplug.inspect}" do
        settings = Fog::Proxmox::HotplugHelper.extract(hotplug)
        assert_equal false, settings[:enabled]
        assert_empty Fog::Proxmox::HotplugHelper::DEVICES & settings[:devices]
      end
    end

    it 'reads an explicit device list' do
      assert_equal({ enabled: true, devices: %w[disk cpu memory] }, Fog::Proxmox::HotplugHelper.extract('disk,cpu,memory'))
    end

    it 'returns an independent default device list' do
      Fog::Proxmox::HotplugHelper.extract(nil)[:devices].clear
      assert_equal %w[disk network usb], Fog::Proxmox::HotplugHelper.extract(nil)[:devices]
    end
  end

  describe '.flatten' do
    it 'serializes selected devices in the existing device order' do
      assert_equal 'disk,network,cpu', Fog::Proxmox::HotplugHelper.flatten(enabled: true, devices: %w[cpu network disk])
    end

    it 'disables hotplug even when devices are selected' do
      assert_equal '0', Fog::Proxmox::HotplugHelper.flatten(enabled: false, devices: %w[disk network])
    end

    it 'disables hotplug when no supported devices are selected' do
      [[], ['unknown']].each do |devices|
        assert_equal '0', Fog::Proxmox::HotplugHelper.flatten(enabled: true, devices: devices)
      end
    end

    it 'round trips explicit supported devices' do
      raw = 'disk,cpu,memory'
      assert_equal raw, Fog::Proxmox::HotplugHelper.flatten(Fog::Proxmox::HotplugHelper.extract(raw))
    end
  end
end
