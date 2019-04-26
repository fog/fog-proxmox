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

      def self.nic_creation_regexp
        /^(\w+)[=]{1}([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2}).+/
      end

      def self.has_model?(nic_value)
        nic_value.match(self.model_regexp)
      end

      def self.has_name?(nic_value)
        nic_value.match(self.name_regexp)
      end

      def self.extract_nic_id(nic_value)
        if self.has_model?(nic_value)
          nic_value.scan(self.model_regexp).first.first
        elsif self.has_name?(nic_value)
          nic_value.scan(self.name_regexp).first.first
        else
          nic_value.scan(self.nic_creation_regexp).first.first
        end
      end

      def self.to_mac_adresses_array(nics)
        addresses = []
        nics.each { |nic| addresses.push(nic.mac) }
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

      def self.flatten(nic)
        nic_id = self.nic_name(nic) + "=" + nic[self.nic_name(nic).to_sym]
        options = nic.reject { |key, _value| [self.nic_name(nic).to_sym, :id].include? key }
        nic_id += ',' + Fog::Proxmox::Hash.stringify(options) unless options.empty?
        { "#{nic[:id]}": nic_id }
      end

      def self.collect_nics(attributes)        
        attributes.select { |key| is_a_nic?(key.to_s) }
      end
    
      def self.is_a_nic?(id)
        NICS_REGEXP.match?(id)
      end
    end
  end
end
