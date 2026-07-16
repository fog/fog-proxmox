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

module Fog
  module Proxmox
    class Compute
      # class Storage model: https://pve.proxmox.com/pve-docs/api-viewer/index.html#/nodes/{node}/storage/{storage}
      class Storage < Fog::Model
        identity  :storage
        attribute :node_id, aliases: :node
        attribute :content
        attribute :type
        attribute :avail
        attribute :total
        attribute :used
        attribute :shared
        attribute :active
        attribute :enabled
        attribute :used_fraction
        attribute :volumes

        def initialize(new_attributes = {})
          prepare_service_value(new_attributes)
          Fog::Proxmox::Attributes.set_attr_and_sym('node_id', attributes, new_attributes)
          Fog::Proxmox::Attributes.set_attr_and_sym('storage', attributes, new_attributes)
          requires :node_id, :storage
          # volumes are initialized last, as it depends on the other attributes
          # having been merged already (see #active?)
          super(new_attributes)
          initialize_volumes
        end

        # Proxmox evaluates a storage per node: a storage may be defined
        # cluster-wide and still be unusable on this node, because it is
        # disabled or restricted to other nodes. Such a storage is still listed
        # by GET /nodes/{node}/storage, but with active (and enabled) set to 0.
        # active is only known for storages built from an API response, so a
        # missing value is assumed to be active.
        def active?
          active.nil? || ![0, '0', false].include?(active)
        end

        private

        # Listing the content of a storage that is not active on this node fails
        # with "storage 'x' is not available on node 'y'" (HTTP 500), so give it
        # an empty, already loaded collection rather than let it lazily query
        # the API. See https://github.com/fog/fog-proxmox/issues/118
        def initialize_volumes
          volumes = Fog::Proxmox::Compute::Volumes.new(service: service, node_id: node_id, storage_id: identity)
          volumes.load([]) unless active?
          attributes[:volumes] = volumes
        end
      end
    end
  end
end
