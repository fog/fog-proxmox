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

require 'fog/proxmox/models/model'

module Fog
  module Compute
    class Proxmox
      # class Snapshot model
      class Snapshot < Fog::Proxmox::Model
        identity  :name
        attribute :description
        attribute :snaptime
        attribute :server

        def to_s
          name
        end

        def create(options = {})
          requires :name, :server
          path_params = { node: server.node, type: server.type, vmid: server.vmid }
          body_params = options.merge(snapname: name)
          service.create_snapshot(path_params, body_params)
        end

        def update
          requires :name, :server
          path_params = { node: server.node, type: server.type, vmid: server.vmid, snapname: name }
          body_params = { description: description }
          service.update_snapshot(path_params, body_params)
        end

        def rollback
          requires :name, :server
          path_params = { node: server.node, type: server.type, vmid: server.vmid, snapname: name }
          service.rollback_snapshot(path_params)
        end

        def destroy(force = 0)
          requires :name, :server
          path_params = { node: server.node, type: server.type, vmid: server.vmid, snapname: name }
          query_params = { force: force }
          taskupid = service.delete_snapshot(path_params, query_params)
          taskupid
        end
      end
    end
  end
end
