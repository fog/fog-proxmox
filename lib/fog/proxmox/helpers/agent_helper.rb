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

module Fog
  module Proxmox
    # Convert guest agent settings to and from Proxmox configuration strings.
    module AgentHelper
      DEFAULTS = {
        'enabled' => '0',
        'freeze-fs-on-backup' => '1',
        'fstrim_cloned_disks' => '0',
        'type' => 'virtio'
      }.freeze

      def self.extract(agent)
        settings = DEFAULTS.dup
        agent.to_s.split(',').each do |option|
          key, value = option.split('=', 2)
          if value.nil?
            settings['enabled'] = key
          else
            settings[key] = value
          end
        end

        settings['freeze-fs-on-backup'] = settings.fetch('freeze-fs', settings['freeze-fs-on-backup'])
        settings
      end

      def self.flatten(settings)
        "enabled=#{settings['enabled']},freeze-fs-on-backup=#{settings['freeze-fs-on-backup']}," \
          "fstrim_cloned_disks=#{settings['fstrim_cloned_disks']},type=#{settings['type']}"
      end
    end
  end
end
