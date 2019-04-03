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
  module Compute
    class Proxmox
      # class Volume model
      class Volume < Fog::Model
        identity  :volid
        attribute :content
        attribute :size
        attribute :format
        attribute :node_id
        attribute :storage_id
        attribute :vmid

        def initialize(new_attributes = {})
          prepare_service_value(new_attributes)
          attributes[:node_id] = new_attributes[:node_id] unless new_attributes[:node_id].nil?
          attributes[:storage_id] = new_attributes[:storage_id] unless new_attributes[:storage_id].nil?
          attributes[:volid] = new_attributes['volid'] unless new_attributes['volid'].nil?
          requires :node_id, :storage_id, :volid
          super(new_attributes)
        end

        def destroy
          service.delete_volume(node_id, storage_id, volid)
        end

        def restore(vmid, options = {})
          service.create_server(node_id, options.merge(archive: volid, storage: storage_id, vmid: vmid))
        end
      end
    end
  end
end
