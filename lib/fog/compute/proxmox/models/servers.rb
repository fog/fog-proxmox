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
        attribute :node_id

        def initialize(attributes = {})
          super(attributes)
        end

        def type
          'qemu'
        end

        def new(attributes = {})
          requires :node_id
          super({ node_id: node_id, type: type }.merge(attributes))
        end

        def next_id
          response = service.next_vmid
          body = JSON.decode(response.body)
          data = body['data']
        end

        def id_valid?(vmid)
          service.check_vmid(vmid)
          true
        rescue Excon::Errors::BadRequest
          false
        end

        def get(vmid)
          requires :node_id
          path_params = { node: node_id, type: type, vmid: vmid }
          server_data = service.get_server_status path_params
          config_data = service.get_server_config path_params
          data = server_data.merge(config_data).merge(node: node_id, vmid: vmid)
          new(data)
        end

        def all(options = {})
          requires :node_id
          body_params = options.merge(node: node_id, type: type)
          load_response(service.list_servers(body_params), 'servers', ['node'])
        end
      end
    end
  end
end
