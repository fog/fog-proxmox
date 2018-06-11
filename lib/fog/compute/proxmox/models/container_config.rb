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

require 'fog/proxmox/variables'
require 'fog/proxmox/nic'

module Fog
  module Compute
    class Proxmox
      # ContainerConfig model
      class ContainerConfig < Fog::Proxmox::Model
        identity  :digest
        attribute :ostype
        attribute :arch
        attribute :memory
        attribute :swap
        attribute :hostname
        attribute :onboot
        attribute :rootfs
        attribute :container

        def initialize(attributes = {})
          prepare_service_value(attributes)
          Fog::Proxmox::Variables.to_variables(self, attributes, 'net')
          Fog::Proxmox::Variables.to_variables(self, attributes, 'mp')
          super({ container: container }.merge(attributes))
        end

        def nics
          Fog::Proxmox::Variables.to_hash(self, 'net')
        end

        def mount_points
          Fog::Proxmox::Variables.to_hash(self, 'mp')
        end

        def mac_addresses
          Fog::Proxmox::Nic.to_mac_adresses_array(nics)
        end

      end
    end
  end
end
