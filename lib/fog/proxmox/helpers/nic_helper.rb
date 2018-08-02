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

      def self.extract_model(nic_value)
        creation = nic_value.match(/^model=(\w+)[,].+/)
        if creation
          nic_value.scan(/^model=(\w+)[,].+/).first.first
        else
          nic_value.scan(/^(\w+)[=]{1}([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2}).+/).first.first
        end
      end

      def self.extract_name(nic_value)
        creation = nic_value.match(/^name=(\w+)[,].+/)
        if creation
          nic_value.scan(/^name=(\w+)[,].+/).first.first
        else
          nic_value.scan(/^(\w+)[=]{1}([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2}).+/).first.first
        end
      end

      def self.to_mac_adresses_array(nics)
        addresses = []
        nics.each { |nic| addresses.push(nic.mac) }
        addresses
      end

      def self.flatten(nic)
        model = "model=#{nic[:model]}"
        options = nic.reject { |key, _value| %i[model id].include? key }
        model += ',' + Fog::Proxmox::Hash.stringify(options) unless options.empty?
        { "#{nic[:id]}": model }
      end

      def self.container_flatten(nic)
        name = "name=#{nic[:name]}"
        options = nic.reject { |key, _value| %i[name id].include? key }
        name += ',' + Fog::Proxmox::Hash.stringify(options) unless options.empty?
        { "#{nic[:id]}": name }
      end

      def self.valid?(key)
        key.to_s.match(/^net(\d+)$/)
      end

      def self.collect_nics(attributes)        
        attributes.select { |key| valid?(key.to_s) }
      end
    end
  end
end
