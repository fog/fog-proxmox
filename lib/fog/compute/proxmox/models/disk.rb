# frozen_string_literal: true
# Copyright 2018 Tristan Robert

# This file is part of Fog::Proxmox.

# Fog::Proxmox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
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

require 'fog/proxmox/models/model'
require 'fog/proxmox/helpers/disk_helper'

module Fog
  module Compute
    class Proxmox
      # class Disk model
      class Disk < Fog::Proxmox::Model
        identity  :id
        attribute :size
        attribute :storage
        attribute :cache
        attribute :replicate
        attribute :media
        attribute :format
        attribute :model
        attribute :shared
        attribute :snapshot
        attribute :backup
        attribute :aio

        CONTROLLERS = %w[ide sata scsi virtio].freeze

        def controller
          Fog::Proxmox::DiskHelper.extract_controller(id)
        end

        def device
          Fog::Proxmox::DiskHelper.extract_device(id)
        end
      end
    end
  end
end
