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

# frozen_string_literal: true

require 'fog/proxmox/hash'

module Fog
  module Proxmox
    class Cluster
      # class Disk model
      class Resource < Fog::Model
        identity  :id

        attribute :name
        attribute :type
        attribute :node

        # generic
        attribute :maxdisk

        # vm/lxc specific
        attribute :vmid
        attribute :status
        attribute :uptime
        attribute :template
        # resources are written in bytes, proxmox displays gibibytes
        attribute :maxcpu
        attribute :maxmem

        # storage specific
        attribute :content
        attribute :shared
        attribute :storage

        def is_template?
          template === 1
        end

        def to_s
          Fog::Proxmox::Hash.flatten(attributes)
        end
      end
    end
  end
end
