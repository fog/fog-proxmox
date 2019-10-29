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
      DISKS_REGEXP = /^(scsi|sata|mp|rootfs|virtio|ide)(\d+){0,1}$/.freeze
      SERVER_DISK_REGEXP = /^(scsi|sata|virtio|ide)(\d+)$/.freeze
      MOUNT_POINT_REGEXP = /^(mp)(\d+)$/.freeze
      ROOTFS_REGEXP = /^(rootfs)$/.freeze
      CDROM_REGEXP = /^(.*)[,]{0,1}(media=cdrom)[,]{0,1}(.*)$/.freeze

      def self.flatten(disk)
        id = disk[:id]
        value = ''
        if disk[:volid]
          value += disk[:volid]
          value += ',size=' + disk[:size].to_s if disk[:size]
        elsif disk[:storage] && disk[:size]
          value += disk[:storage] + ':' + disk[:size].to_s
        elsif id == 'ide2'
          value += 'none'
        end
        opts = disk[:options] if disk[:options]
        main_a = [:id, :volid, :storage, :size]
        opts ||= disk.reject { |key, _value| main_a.include? key }
        options = ''
        options += Fog::Proxmox::Hash.stringify(opts) if opts
        if id == 'ide2' && !cdrom?(options)
          options += ',' unless options.empty?
          options += 'media=cdrom'
        end
        value += ',' if !options.empty? && !value.empty?
        value += options
        { "#{id}": value }
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
        # volid definition: <VOULME_ID>:=<STORAGE_ID>:<storage type dependent volume name>
        values_a = disk_value.scan(/^(([\w-]+)[:]{0,1}([\w\/\.-]+))/)
        no_cdrom = !disk_value.match(CDROM_REGEXP)
        creation = disk_value.split(',')[0].match(/^(([\w-]+)[:]{1}([\d]+))$/)
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

      def self.to_bytes(size)
        val = size.match(/\d+(\w?)/)
        m = 0
        case val[1]
        when 'K' then m = 1
        when 'M' then m = 2
        when 'G' then m = 3
        when 'T' then m = 4
        when 'P' then m = 5
        end
        val[0].to_i * 1024**m
      end

      def self.extract_size(disk_value)
        size = extract_option('size', disk_value)
        size ? to_bytes(size) : '1G'
      end

      def self.disk?(id)
        DISKS_REGEXP.match(id) ? true : false
      end

      def self.cdrom?(value)
        CDROM_REGEXP.match(value) ? true : false
      end

      def self.server_disk?(id)
        SERVER_DISK_REGEXP.match(id) ? true : false
      end

      def self.rootfs?(id)
        ROOTFS_REGEXP.match(id) ? true : false
      end

      def self.mount_point?(id)
        MOUNT_POINT_REGEXP.match(id) ? true : false
      end

      def self.container_disk?(id)
        rootfs?(id) || mount_point?(id)
      end
    end
  end
end
