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
          options.store(:snapname, name)
          service.create_snapshot(server.node, server.vmid, options)
        end

        def update
          requires :name, :server
          service.update_snapshot(server.node, server.vmid, name, description)
        end

        def rollback
          requires :name, :server
          service.rollback_snapshot(server.node, server.vmid, name)
        end

        def destroy(force = 0)
          requires :name, :server
          taskupid = service.delete_snapshot(server.node, server.vmid, name, force)
          taskupid
        end
      end
    end
  end
end
