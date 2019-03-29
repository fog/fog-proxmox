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

require 'fog/identity/proxmox/models/permission'

module Fog
  module Identity
    class Proxmox
      # class Permissions authentication
      class Permissions < Fog::Collection
        model Fog::Identity::Proxmox::Permission
        
        def new(options = {})
          groups = options[:groups]
          users = options[:users]
          roles = options[:roles]
          path = options[:path]
          requires groups, users, roles, path
          propagate ||= 1
          if groups
            type = 'group'
            ugid = groups
          elsif users
            type = 'user'
            ugid = users
          end
          super(path: path, propagate: propagate, roleid: roles, type: type, ugid: ugid)
        end

        def all
          load service.list_permissions
        end
      end
    end
  end
end
