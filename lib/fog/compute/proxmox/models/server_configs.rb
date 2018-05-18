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

require 'fog/compute/proxmox/models/server_config'

module Fog
  module Compute
    class Proxmox
      # ServerConfigs collection
      class ServerConfigs < Fog::Proxmox::Collection
        model Fog::Compute::Proxmox::ServerConfig
        attribute :server

        def new(attributes = {})
          requires :server
          super({ server: server }.merge(attributes))
        end

        def all
          load_response(service.list_server_configs(server.node, server.vmid), 'server_configs')
        end

        def nics
          all
          select { |config| config.key.start_with? 'net' }
        end

        def get(key)
          all
          cached_config = find { |config| config.key == key }
          return cached_config if cached_config
        end

        def detach(key)
          config = get(key)
          config.detach
        end

        def destroy(key)
          config = get(key)
          config.destroy
        end
      end
    end
  end
end
