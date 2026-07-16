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

module Fog
  module Proxmox
    class Identity
      # class Real get_pool collection
      class Real
        def get_pool(poolid)
          # Use the modern GET /pools?poolid=X endpoint. The historical
          # GET /pools/{poolid} is deprecated in Proxmox VE and returns
          # 501 Not Implemented for nested pool ids (e.g. 'foo/bar'),
          # which breaks Pools#all against any cluster that uses them.
          # See fog/fog-proxmox#130.
          response = request(
            expects: [200],
            method: 'GET',
            path: 'pools',
            query: { poolid: poolid }
          )
          # The endpoint returns an array of matching pools; unwrap the
          # single element to keep the historical return signature.
          response.is_a?(Array) ? (response.first || {}) : response
        end
      end

      # class Mock get_pool collection
      class Mock
        def get_pool(poolid); end
      end
    end
  end
end
