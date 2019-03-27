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
require 'fog/compute/proxmox/models/volume'

module Fog
  module Compute
    class Proxmox
      # class Volumes Collection of volumes
      class Volumes < Fog::Proxmox::Collection
        model Fog::Compute::Proxmox::Volume
        attribute :node_id
        attribute :storage_id

        def new(attributes = {})
          requires :node_id, :storage_id
          super({ node_id: node_id, storage_id: storage_id }.merge(attributes))
        end

        def all
          search
        end

        def search(options = {})
          requires :node_id, :storage_id
          load_response(service.list_volumes(node_id, storage_id, options), 'volumes')
        end

        def list_by_content_type(content)
          search(content: content)
        end

        def list_by_content_type_and_by_server(content, vmid)
          search(content: content, vmid: vmid)
        end

        def get(id)
          all
          cached_volume = find { |volume| volume.id == id }
          return cached_volume if cached_volume
        end

        def destroy(id)
          volume = get(id)
          volume.destroy
        end
      end
    end
  end
end
