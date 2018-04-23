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
require 'fog/identity/proxmox/models/role'

module Fog
  module Identity
    class Proxmox
      class Roles < Fog::Proxmox::Collection
        model Fog::Identity::Proxmox::Role

        def all(_options = {})
          # special attibute is volatile in role
          load_response(service.list_roles, 'roles', ['special'])
        end

        def find_by_id(id)
          cached_role = find { |role| role.roleid == id }
          return cached_role if cached_role
          role_hash = service.get_role(id)
          Fog::Identity::Proxmox::Role.new(
            role_hash.merge(service: service)
          )
        end

        def destroy(id)
          role = find_by_id(id)
          role.destroy
        end
      end
    end
  end
end
