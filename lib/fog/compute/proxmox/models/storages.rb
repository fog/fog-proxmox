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
require 'fog/compute/proxmox/models/storage'

module Fog
  module Compute
    class Proxmox
      # class Storages Collection of storages
      class Storages < Fog::Proxmox::Collection
        model Fog::Compute::Proxmox::Storage

        def all
          search
        end

        def search(node, options = {})
          load_response(service.list_storages(node,options), 'storages')
        end

        def list_store_images(node)
          options = { content: 'images'}
          load_response(service.list_storages(node,options), 'storages')
        end

        def find_by_id(id)
          cached_storage = find { |storage| storage.id == id }
          return cached_storage if cached_storage
          storage_hash = service.get_storage(id)
          Fog::Compute::Proxmox::Storage.new(
            storage_hash.merge(service: service)
          )
        end
      end
    end
  end
end
