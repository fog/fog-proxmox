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

module Fog
  module Identity
    class Proxmox
      # class Group model authentication
      class Group < Fog::Model
        identity  :groupid
        attribute :comment

        def save(options = {})
          service.create_group(attributes.merge(options))
          reload
        end

        def destroy
          requires identity
          service.delete_group(groupid)
          true
        end

        def update
          requires identity
          service.update_group(identity, attributes.reject { |attribute| [:groupid].include? attribute })
          reload
        end
      end
    end
  end
end
