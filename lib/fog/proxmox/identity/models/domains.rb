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

require 'fog/proxmox/identity/models/domain'

module Fog
  module Proxmox
    class Identity
      # class Domains collection authentication
      class Domains < Fog::Collection
        model Fog::Proxmox::Identity::Domain

        def all
          load service.list_domains
        end

        def get(id)
          all.find { |domain| domain.identity == id }
        end

        def destroy(id)
          domain = get(id)
          domain.destroy
        end
      end
    end
  end
end
