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

require 'fog/proxmox/hash'

module Fog
  module Proxmox
    # module NicHelper mixins
    module NicHelper
      def self.extract_mac_address(nic_value)
        nic_value[/([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})/]
      end
      def self.extract(name,nic_value)
        nic_value[/(#{name}=(\w+))[,]{0,1}/]
      end
      def self.extract_model(nic_value)
        nic_value[/^(\w+)[=\w+][,]{0,1}/]
      end
      def self.extract_index(nic_key)
        nic_key[/net(\d+)/].to_i
      end
      def self.last_index(nics)
        indexes = []
        nics.each_key { |key| indexes.push(extract_index(key)) }
        indexes.sort
        indexes.last
      end
      def self.to_mac_adresses_array(nics)
        addresses = []
        nics.each_value { |value| addresses.push(extract_mac_address(value)) }
        addresses
      end
      def self.flatten(nic)
        model = "model=#{nic[:model]}"
        options = nic.reject { |key,_value| [:model,:id].include? key }
        model += ',' + Fog::Proxmox::Hash.stringify(options) if !options.empty?
        { "#{nic[:id]}": model }
      end
    end
  end
end
