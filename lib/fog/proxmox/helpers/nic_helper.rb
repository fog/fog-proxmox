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

      NICS_REGEXP = /^(net)(\d+)/

      def self.extract_mac_address(nic_value)
        nic_value[/([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})/]
      end

      def self.model_regexp
        /^model=(\w+)[,].+/
      end

      def self.name_regexp
        /^name=(\w+)[,].+/
      end

      def self.ip_regexp
        /^(.+)[,]{1}ip=([\d\.\/]+)[,]?(.+)?$/
      end

      def self.nic_update_regexp
        /^(\w+)[=]{1}([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2}).+/
      end

      def self.has_model?(nic_value)
        nic_value.match?(self.model_regexp)
      end

      def self.has_name?(nic_value)
        nic_value.match?(self.name_regexp)
      end

      def self.has_ip?(nic_value)
        nic_value.match?(self.ip_regexp)
      end

      def self.extract_nic_id(nic_value)
        if self.has_model?(nic_value)
          nic_value.scan(self.model_regexp).first.first
        elsif self.has_name?(nic_value)
          nic_value.scan(self.name_regexp).first.first
        else
          nic_value.scan(self.nic_update_regexp).first.first
        end
      end

      def self.to_mac_adresses_array(nics)
        addresses = []
        nics.each { |nic| addresses.push(nic.macaddr) }
        addresses
      end

      def self.nic_name(nic)
        if nic.has_key?(:model)
          "model"
        elsif nic.has_key?(:name)
          "name"
        else
          ""
        end
      end

      def self.set_mac(nic_id, nic_hash)
        mac_keys = [:macaddr, :hwaddr]
        nic_value = ''
        if (nic_hash.keys & mac_keys).empty?
          nic_value = self.nic_name(nic_hash) + "=" + nic_id
        else
          mac_value = nic_hash[mac_keys[0]] if nic_hash.key?(mac_keys[0])
          mac_value ||= nic_hash[mac_keys[1]] if nic_hash.key?(mac_keys[1])
          nic_value = nic_id + "=" + mac_value
        end
        nic_value
      end

      # Convert nic attributes hash into API Proxmox parameters string 
      def self.flatten(nic_hash)
        nic_id = nic_hash[self.nic_name(nic_hash).to_sym]
        nic_value = self.set_mac(nic_id, nic_hash)
        options = nic_hash.reject { |key, _value| [self.nic_name(nic_hash).to_sym,:id,:macaddr,:hwaddr].include? key.to_sym }
        nic_value += ',' unless options.empty?
        nic_value += Fog::Proxmox::Hash.stringify(options) unless options.empty?
        { "#{nic_hash[:id]}": nic_value }
      end

      def self.collect_nics(attributes)        
        attributes.select { |key| nic?(key.to_s) }
      end
    
      def self.nic?(id)
        NICS_REGEXP.match(id) ? true : false
      end

      def self.extract_ip(nic_value)
        if ip = self.ip_regexp.match(nic_value)
          ip[2]
        end
      end
    end
  end
end
