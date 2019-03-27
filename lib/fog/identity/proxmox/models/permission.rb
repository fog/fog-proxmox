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

module Fog
  module Identity
    class Proxmox
      # class Permission
      class Permission < Fog::Model
        attribute :type
        attribute :ugid
        attribute :roleid
        attribute :path
        attribute :propagate

        def to_s
          "path=#{path},roleid=#{roleid},type=#{type},ugid=#{ugid}"
        end

        def ==(other)
          to_s.eql? other.to_s if other
        end

        def add
          service.add_permission(to_request)
        end

        def remove
          service.remove_permission(to_request)
        end

        def to_request
          request = { roles: roleid, path: path, propagate: propagate }
          if type == 'group'
            request.store(:groups, ugid)
          elsif type == 'user'
            request.store(:users, ugid)
          end
          request
        end
      end
    end
  end
end
