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

require 'fog/proxmox/models/collection'
require 'fog/compute/proxmox/models/snapshot'

module Fog
  module Compute
    class Proxmox
      # class Snapshots Collection of snapshots
      class Snapshots < Fog::Proxmox::Collection
        model Fog::Compute::Proxmox::Snapshot
        attribute :server

        def new(attributes = {})
          requires :server
          super({ server: server }.merge!(attributes))
        end

        def all
          requires :server
          path_params = { node: server.node, type: server.type, vmid: server.vmid }
          load_response(service.list_snapshots(path_params), 'snapshots')
        end

        def get(name)
          requires :server
          cached_snapshot = find { |snapshot| snapshot.name == name }
          return cached_snapshot if cached_snapshot
          path_params = { node: server.node, type: server.type, vmid: server.vmid, snapname: name }
          snapshot_hash = service.get_snapshot(path_params)
          Fog::Compute::Proxmox::Snapshot.new(
            snapshot_hash.merge(service: service, server: server, name: name)
          )
        end
      end
    end
  end
end
