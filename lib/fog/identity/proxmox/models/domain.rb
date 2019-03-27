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
      # class Domain model authentication
      class Domain < Fog::Model
        identity :realm
        attribute :type
        def to_s
          realm
        end

        def create(new_attributes = {})
          attr = type.attributes.merge(new_attributes).merge(realm: realm)
          service.create_domain(attr)
        end

        def destroy
          requires :realm
          service.delete_domain(realm)
          true
        end

        def update
          requires :realm
          attr = type.attributes
          attr.delete_if { |key, _value| key == :type }
          service.update_domain(realm, attr)
        end
      end
    end
  end
end
