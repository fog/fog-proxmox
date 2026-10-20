# frozen_string_literal: true

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

require 'fog/proxmox/helpers/rng_helper'

module Fog
  module Proxmox
    class Compute
      # VirtIO RNG device; period is in milliseconds and max_bytes is in bytes.
      class Rng < Fog::Model
        attribute :max_bytes
        attribute :period
        attribute :source

        def flatten
          Fog::Proxmox::RngHelper.flatten(attributes)
        end
      end
    end
  end
end
