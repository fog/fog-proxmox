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

# frozen_string_literal: true

module Fog
  module Compute
    module Proxmox
      # Disk type class
      class DiskType
        include Enumerable

        def each
          (0..3).each do |i|
            yield 'ide' + i
          end
          (0..13).each do |i|
            yield 'scsi' + i
          end
          (0..15).each do |i|
            yield 'virtio' + i
          end
          (0..5).each do |i|
            yield 'sata' + i
          end
          yield 'efidisk0'
        end
      end
    end
  end
end
