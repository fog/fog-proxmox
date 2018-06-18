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

require 'fog/proxmox/models/model'

module Fog
  module Compute
    class Proxmox
      # class Volume model
      class Volume < Fog::Proxmox::Model
        identity  :volid
        attribute :content
        attribute :size
        attribute :format
        attribute :node
        attribute :storage
        attribute :vmid

        def new(attributes = {})
          requires :node, :storage
          super({ node: node, storage: storage }.merge(attributes))
        end

        def destroy
          requires :node, :volid, :storage
          service.delete_volume(node, storage, volid)
        end

        def restore(vmid, options = {})
          requires :node, :volid, :storage
          service.create_server(node, options.merge(archive: volid, storage: storage, vmid: vmid))
        end 
      end
    end
  end
end
