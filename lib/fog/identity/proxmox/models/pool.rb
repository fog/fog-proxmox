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
  module Identity
    class Proxmox
      # class Pool model of VMs
      class Pool < Fog::Proxmox::Model
        identity  :poolid
        attribute :comment
        attribute :members
        
        def to_s
          poolid
        end

        def create
          service.create_pool(attributes)
        end

        def destroy
          requires :poolid
          service.delete_pool(poolid)
          true
        end

        def add_server(server)
          update_with_member('vms',server,false)
        end

        def add_storage(storage)
          update_with_member('storage',storage,false)
        end

        def remove_storage(storage)
          update_with_member('storage',storage,true)
        end

        def remove_server(server)
          update_with_member('vms',server,true)
        end

        def update_with_member(member_name,member_id,delete = false)
          requires :poolid
          attr = attributes.reject { |k, _v| [:poolid,:members].include? k }
          attr.store(member_name,member_id) if member_name
          attr.store('delete',1) if delete
          service.update_pool(poolid, attr)
        end

        def update
          update_with_member(nil,nil,false)
        end
      end
    end
  end
end
