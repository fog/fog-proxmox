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

module Fog
  module Proxmox
    # module ControllerHelper mixins
    module ControllerHelper
      def self.extract(name,controller_value)
        values = controller_value.scan(/#{name}=(\w+)/)
        name_value = values.first if values
        name_value.first if name_value
      end
      def self.extract_index(name,key)
        key.to_s.scan(/#{name}(\d+)/).first.first.to_i
      end
      def self.valid?(name,key)
       key.to_s.match(/#{name}(\d+)/)
      end
      def self.last_index(name,values)
        return -1 if values.empty?
        indexes = []
        values.each_key { |key| indexes.push(extract_index(name,key)) }
        indexes.sort
        indexes.last
      end      
      def self.to_variables(instance, hash, name)
        hash.select { |key| valid?(name,key.to_s) }.each do |key, value|
          instance.instance_variable_set "@#{key}".to_sym, value
        end
      end
      def self.to_hash(instance, name)
        hash = {}
        name = '@' + name
        instance.instance_variables.select { |variable| valid?(name,variable.to_s) }.each do |param|
          name = param.to_s[1..-1]
          hash.store(name.to_sym, instance.instance_variable_get(param))
        end
        hash
      end
    end
  end
end
