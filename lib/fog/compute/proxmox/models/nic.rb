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
  module Compute
    class Proxmox
      # class Nic model
      class Nic < Fog::Proxmox::Model
        identity  :id
        attribute :mac
        attribute :model
        attribute :bridge
        attribute :firewall
        attribute :link_down
        attribute :rate
        attribute :queues
        attribute :tag
        attribute :server_config

        def to_s
          self.id.to_s
        end

        def initialize(hash)
          self.id = hash[:id]
          self.server_config = hash[:server_config]
          self.model = hash[:model]
          self.mac = hash[:mac]
          self.bridge = hash[:bridge]
          self.firewall = hash[:firewall]
          self.link_down = hash[:link_down]
          self.rate = hash[:rate]
          self.queues = hash[:queues]
          self.tag = hash[:tag]        
        end

      end
    end
  end
end
