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
      def self.extract(name, controller_value)
        values = controller_value.scan(/#{name}=(\w+)/)
        name_value = values.first if values
        name_value&.first
      end

      def self.extract_index(name, key)
        idx_a = key.to_s.scan(/#{name}(\d+)/).first
        idx_a.first.to_i if idx_a
      end

      def self.valid?(name, key)
        key.to_s.match(/#{name}(\d+)/)
      end

      def self.last_index(name, values)
        return -1 if values.empty?
        indexes = []
        values.each do |value|
          index = extract_index(name, value)
          indexes.push(index) if index
        end
        indexes.sort
        indexes.empty? ? -1 : indexes.last
      end

      def self.to_hash(hash, name)
        hash.select { |key| valid?(name, key.to_s) }
      end
    end
  end
end
