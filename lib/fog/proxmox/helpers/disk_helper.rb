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
    # module Disk mixins
    module DiskHelper
      def self.flatten(disk)
        volid = disk[:volid]
        value = if volid
                  "#{disk[:volid]},size=#{disk[:size]}"
                else
                  "#{disk[:storage]}:#{disk[:size]}"
                end
        options = Fog::Proxmox::Hash.stringify(disk[:options])
        value += ",#{options}" unless options.empty?
        { "#{disk[:id]}": value }
      end

      def self.extract_controller(id)
        extract(id)[0]
      end

      def self.extract_device(id)
        extract(id)[1].to_i
      end

      def self.extract(id)
        id.scan(/(\w+)(\d+)/).first
      end

      def self.extract_option(name, disk_value)
        values = disk_value.scan(/#{name}=(\w+)/)
        name_value = values.first if values
        name_value&.first
      end

      def self.extract_storage_volid_size(disk_value)
        values_a = disk_value.scan(/^(([\w-]+)[:]{0,1}([\w\/\.-]+))/)
        no_cdrom = !disk_value.match(/^(.+)[,]{1}(media=cdrom)$/)
        creation = disk_value.match(/^(([\w-]+)[:]{1}([\d]+))/)
        values = values_a.first if values_a
        if no_cdrom
          if creation
            storage = values[1]
            volid = nil
            size = values[2].to_i
          else
            storage = values[1]
            volid = values[0]
            size = extract_size(disk_value)
          end
        else
          volid = values[0]
          storage = values[1] unless %w[none cdrom].include? volid
          size = nil
        end
        [storage, volid, size]
      end

      def self.extract_size(disk_value)
        extract_option('size', disk_value).to_i
      end
    end
  end
end
