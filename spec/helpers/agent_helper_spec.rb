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
require 'fog/proxmox/helpers/agent_helper'

describe 'AgentHelper' do
  describe '.extract' do
    [nil, '', '0', 0].each do |agent|
      it "uses disabled defaults for #{agent.inspect}" do
        assert_equal Fog::Proxmox::AgentHelper::DEFAULTS, Fog::Proxmox::AgentHelper.extract(agent)
      end
    end

    ['1', 1, 'enabled=1'].each do |agent|
      it "reads enabled shorthand #{agent.inspect}" do
        expected = Fog::Proxmox::AgentHelper::DEFAULTS.merge('enabled' => '1')
        assert_equal expected, Fog::Proxmox::AgentHelper.extract(agent)
      end
    end

    it 'reads explicit options even when disabled' do
      settings = Fog::Proxmox::AgentHelper.extract('enabled=0,freeze-fs-on-backup=0,fstrim_cloned_disks=1,type=isa')
      assert_equal({ 'enabled' => '0', 'freeze-fs-on-backup' => '0', 'fstrim_cloned_disks' => '1', 'type' => 'isa' }, settings)
    end

    it 'prefers freeze-fs regardless of option order' do
      ['freeze-fs=0,freeze-fs-on-backup=1', 'freeze-fs-on-backup=1,freeze-fs=0'].each do |options|
        assert_equal '0', Fog::Proxmox::AgentHelper.extract("1,#{options}")['freeze-fs-on-backup']
      end
    end

    it 'splits option values at only the first equals sign' do
      assert_equal 'a=b', Fog::Proxmox::AgentHelper.extract('type=a=b')['type']
    end

    it 'returns independent settings without changing defaults' do
      Fog::Proxmox::AgentHelper.extract(nil)['enabled'] = '1'
      assert_equal '0', Fog::Proxmox::AgentHelper.extract(nil)['enabled']
    end
  end

  describe '.flatten' do
    %w[0 1].each do |enabled|
      it "serializes all options with enabled=#{enabled}" do
        settings = { 'enabled' => enabled, 'freeze-fs-on-backup' => '0', 'fstrim_cloned_disks' => '1', 'type' => 'isa' }
        assert_equal "enabled=#{enabled},freeze-fs-on-backup=0,fstrim_cloned_disks=1,type=isa", Fog::Proxmox::AgentHelper.flatten(settings)
        assert_equal settings, Fog::Proxmox::AgentHelper.extract(Fog::Proxmox::AgentHelper.flatten(settings))
      end
    end
  end
end
