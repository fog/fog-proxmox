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
require 'fog/proxmox/helpers/nic_helper'

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

        def to_s
          digest
        end

        def initialize(attributes = {})
          prepare_service_value(attributes)
          Fog::Proxmox::Variables.to_variables(self, attributes, 'net')
          Fog::Proxmox::Variables.to_variables(self, attributes, 'mp')
          super({ container: container }.merge(attributes))
        end

        def nets
          Fog::Proxmox::Variables.to_hash(self, 'net')
        end

        def nics
          nics = []
          nets.each do |key,value|
            nics.push(
              Fog::Compute::Proxmox::Nic.new(
                server_config: self, 
                id: key, 
                model: Fog::Proxmox::NicHelper.extract_model(value),
                mac: Fog::Proxmox::NicHelper.extract_mac_address(value),
                bridge: Fog::Proxmox::NicHelper.extract('bridge',value),
                firewall: Fog::Proxmox::NicHelper.extract('firewall',value),
                link_down: Fog::Proxmox::NicHelper.extract('link_down',value),
                rate: Fog::Proxmox::NicHelper.extract('rate',value),
                queues: Fog::Proxmox::NicHelper.extract('queues',value),
                tag: Fog::Proxmox::NicHelper.extract('tag',value)
              )
            )
          end
          nics
        end

        def mount_points
          Fog::Proxmox::Variables.to_hash(self, 'mp')
        end

        def mac_addresses
          Fog::Proxmox::NicHelper.to_mac_adresses_array(nets)
        end

      end
    end
  end
end
