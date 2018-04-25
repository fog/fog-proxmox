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

# frozen_string_literal: true

require 'fog/proxmox/json'

module Fog
  module Compute
    class Proxmox
      # class Real get_server collection
      class Real
        def get_server(node, vmid)
          response = request(
            expects: [200],
            method: 'GET',
            path: "nodes/#{node}/qemu/#{vmid}/status/current"
          )
          Fog::Proxmox::Json.get_data(response)
        end
      end

      # class Mock get_server collection
      class Mock
      end
    end
  end
end
