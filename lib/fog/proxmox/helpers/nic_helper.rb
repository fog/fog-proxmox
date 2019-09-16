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
      NICS_REGEXP = /^(net)(\d+)/.freeze

      def self.extract_mac_address(nic_value)
        nic_value[/([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})/]
      end

      def self.model_regexp
        /^model=(\w+)[,].+/
      end

      def self.name_regexp
        /^name=(\w+)[,].+/
      end

      def self.nic_update_regexp
        /^(\w+)[=]{1}([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2}).+/
      end

      def self.model?(nic_value)
        nic_value.match(model_regexp)
      end

      def self.name?(nic_value)
        nic_value.match(name_regexp)
      end

      def self.extract_nic_id(nic_value)
        if model?(nic_value)
          nic_value.scan(model_regexp).first.first
        elsif name?(nic_value)
          nic_value.scan(name_regexp).first.first
        else
          nic_value.scan(nic_update_regexp).first.first
        end
      end

      def self.to_mac_adresses_array(nics)
        addresses = []
        nics.each { |nic| addresses.push(nic.macaddr) }
        addresses
      end

      def self.nic_name(nic)
        if nic.key?(:model)
          'model'
        elsif nic.key?(:name)
          'name'
        else
          ''
        end
      end

      def self.flatten(nic_hash)
        nic_id = nic_hash[nic_name(nic_hash).to_sym]
        nic_value = if nic_hash.key?(:macaddr)
                      nic_id + '=' + nic_hash[:macaddr]
                    else
                      nic_name(nic_hash) + '=' + nic_id
                    end
        options = nic_hash.reject { |key, _value| [nic_name(nic_hash).to_sym, :id, :macaddr].include? key.to_sym }
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
    end
  end
end
