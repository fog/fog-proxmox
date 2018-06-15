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
      # class Nodes Collection of nodes of cluster
      class Nodes < Fog::Proxmox::Collection
        model Fog::Network::Proxmox::Node

        def all(_options = {})
          load_response(service.list_nodes, 'nodes')
        end

        def find_by_id(id)
          cached_node = find { |node| node.node == id }
          return cached_node if cached_node
          node_hash = service.get_node(id)
          Fog::Network::Proxmox::Node.new(
            node_hash.merge(service: service, node: id)
          )
        end
      end
    end
  end
end
