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
      # class Group model authentication
      class Group < Fog::Proxmox::Model
        identity  :groupid
        attribute :comment
        def to_s
          groupid
        end

        def create(new_attributes = {})
          service.create_group(attributes.merge(new_attributes))
        end

        def destroy
          requires :groupid
          service.delete_group(groupid)
          true
        end

        def update
          requires :groupid
          attr = attributes.reject { |key, _value| key == :groupid }
          service.update_group(groupid, attr)
        end
      end
    end
  end
end
