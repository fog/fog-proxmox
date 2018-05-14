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

module Fog
  module Compute
    class Proxmox
      # class Volume model
      class Volume < Fog::Proxmox::Model
        identity  :id
        attribute :status
        attribute :disk
        attribute :maxdisk
        attribute :storage
        attribute :server

        def new(attributes = {})
          if server
            super({ server: server }.merge!(attributes))
          else
            super
          end
        end

        def to_s
          id
        end

        def attach(options = {})
          requires :id, :node, :server
          config = options.merge(disk: id)
          task_upid = service.update_server(node, server.vmid, config)
          task_upid
        end

        def detach
          requires :id, :node, :server
          config = { delete: id }
          task_upid = service.update_server(node, server.vmid, config)
          task_upid
        end

        def resize(size, options = {})
          requires :id, :node, :server
          config = options.merge(disk: id, size: size)
          task_upid = service.resize_volume(server.node, server.vmid, config)
          task_upid
        end

        def move(storage, options = {})
          requires :id, :node, :server
          config = options.merge(disk: id, storage: storage)
          task_upid = service.move_volume(server.node, server.vmid, config)
          task_upid
        end
      end
    end
  end
end
