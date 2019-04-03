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

require 'fog/compute/proxmox/models/server'

module Fog
  module Compute
    class Proxmox
      # Servers Collection
      class Servers < Fog::Collection
        model Fog::Compute::Proxmox::Server
        attribute :node_id

        def type
          'qemu'
        end

        def new(new_attributes = {})
          super({ node_id: node_id, type: type }.merge(new_attributes))
        end

        def next_id
          service.next_vmid
        end

        def id_valid?(vmid)
          service.next_vmid(vmid: vmid)
          true
        rescue Excon::Errors::BadRequest
          false
        end

        def get(id)
          path_params = { node: node_id, type: type, vmid: id }
          status_data = service.get_server_status path_params
          config_data = service.get_server_config path_params
          data = status_data.merge(config_data).merge(node: node_id, vmid: id)
          new(data)
        end

        def all(options = {})
          body_params = options.merge(node: node_id, type: type)
          load service.list_servers(body_params)
        end
      end
    end
  end
end
