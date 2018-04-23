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
require 'fog/identity/proxmox/models/group'

module Fog
  module Identity
    class Proxmox
      class Groups < Fog::Proxmox::Collection
        model Fog::Identity::Proxmox::Group

        def all(_options = {})
          load_response(service.list_groups, 'groups')
        end

        def find_by_id(id)
          cached_group = find { |group| group.groupid == id }
          return cached_group if cached_group
          group_hash = service.get_group(id)
          Fog::Identity::Proxmox::Group.new(
            group_hash.merge(service: service)
          )
        end

        def destroy(id)
          group = find_by_id(id)
          group.destroy
        end
      end
    end
  end
end
