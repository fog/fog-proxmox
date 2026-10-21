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
    # Convert hotplug settings to and from Proxmox configuration strings.
    module HotplugHelper
      DEVICES = %w[disk network usb cpu memory].freeze
      DEFAULTS = %w[disk network usb].freeze

      def self.extract(hotplug)
        hotplug = hotplug.to_s
        {
          enabled: hotplug != '0',
          devices: hotplug.empty? || hotplug == '1' ? DEFAULTS.dup : hotplug.split(',')
        }
      end

      def self.flatten(settings)
        return '0' unless settings[:enabled]

        devices = DEVICES.select { |device| settings[:devices].include?(device) }
        devices.empty? ? '0' : devices.join(',')
      end
    end
  end
end
