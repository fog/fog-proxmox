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
require 'fog/identity/proxmox/models/permission'

module Fog
  module Identity
    class Proxmox
      # class Permissions authentication
      class Permissions < Fog::Proxmox::Collection
        model Fog::Identity::Proxmox::Permission

        def all(_options = {})
          load_response(service.list_permissions, 'permissions')
        end

        def create(permission_hash)
          groups = permission_hash[:groups]
          users = permission_hash[:users]
          roles = permission_hash[:roles]
          path = permission_hash[:path]
          propagate ||= 1
          permission = new(path: path, propagate: propagate, roleid: roles)
          if groups
            permission.type = 'group'
            permission.ugid = groups
          elsif users
            permission.type = 'user'
            permission.ugid = users
          end
          permission
        end

        def add(permission)
          create(permission).add
        end

        def remove(permission)
          create(permission).remove
        end
      end
    end
  end
end
