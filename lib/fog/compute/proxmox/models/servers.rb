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
      class Servers < Fog::Proxmox::Collection
        model Fog::Compute::Proxmox::Server
        attribute :node
        attribute :type

        def initialize(attributes = {})
          type = attributes[:type] unless type
          super({ node: node, type: type }.merge(attributes))
        end

        def new(attributes = {})
          requires :node, :type
          super({ node: node, type: type }.merge(attributes))
        end

        def next_id
          response = service.next_vmid
          body = JSON.decode(response.body)
          data = body['data']
          Integer(data)
        end

        def id_valid?(vmid)
          service.check_vmid(vmid)
          true
        rescue Excon::Errors::BadRequest
          false
        end

        def get(vmid)
          requires :node
          path_params = { node: node, type: type, vmid: vmid }
          data = service.get_server_status(path_params)
          server_data = data.merge(node: node, vmid: vmid)
          new(server_data)
        end

        def all
          load_response(service.list_servers, 'servers')
        end
      end
    end
  end
end
