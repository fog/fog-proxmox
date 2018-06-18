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
require 'fog/network/proxmox/models/node'

module Fog
  module Network
    class Proxmox
      # class Networks Collection of nodes of cluster
      class Networks < Fog::Proxmox::Collection
        model Fog::Network::Proxmox::Network
        attribute :node

        def new(attributes = {})
          requires :node
          super({ node: node }.merge(attributes))
        end

        def all(options = {})
          requires :node
          path_params = { node: node }
          query_params = options
          load_response(service.list_networks(path_params, query_params), 'networks')
        end

        def find_by_id(id)
          cached_network = find { |network| network.iface == id }
          return cached_network if cached_network
          network_hash = service.get_network(id)
          Fog::Network::Proxmox::Network.new(
            network_hash.merge(service: service, node: node, iface: id)
          )
        end
      end
    end
  end
end
