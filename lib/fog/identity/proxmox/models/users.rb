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
require 'fog/identity/proxmox/models/user'

module Fog
  module Identity
    class Proxmox
      class Users < Fog::Proxmox::Collection
        model Fog::Identity::Proxmox::User

        def all(options = {})
          load_response(service.list_users(options), 'users')
        end

        def find_by_id(id)
          cached_user = find { |user| user.userid == id }
          return cached_user if cached_user
          user_hash = service.get_user(id)
          Fog::Identity::Proxmox::User.new(
            user_hash.merge(service: service)
          )
        end

        def destroy(id)
          user = find_by_id(id)
          user.destroy
        end
      end
    end
  end
end
