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
  module Network
    class Proxmox
      # class Network model
      class Network < Fog::Proxmox::Model
        identity  :iface
        attribute :node
        attribute :comments
        attribute :active
        attribute :autostart
        attribute :type
        attribute :gateway
        attribute :priority
        attribute :exists
        attribute :method
        attribute :method6
        attribute :netmask
        attribute :address
        attribute :families
        attribute :bridge_stp
        attribute :bridge_fd
        attribute :bridge_ports

        TYPES = %w[bridge bond eth alias vlan OVSBridge OVSBond OVSPort OVSIntPort any_bridge].freeze

        def to_s
          identity
        end

        def create(attributes = {})
          requires :node
          path_params = { node: node }
          body_params = attributes
          service.create_network(path_params, body_params)
        end

        def update(attributes = {})
          requires :node, :iface, :type
          path_params = { node: node, iface: iface }
          body_params = attributes.merge(type: type)
          service.update_network(path_params, body_params)
        end

        def destroy
          requires :node, :iface
          path_params = { node: node, iface: iface }
          service.delete_network(path_params)
        end
      end
    end
  end
end
