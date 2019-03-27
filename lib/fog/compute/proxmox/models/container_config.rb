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
require 'fog/proxmox/helpers/controller_helper'

module Fog
  module Compute
    class Proxmox
      # ContainerConfig model
      class ContainerConfig < Fog::Model
        identity  :vmid
        attribute :digest
        attribute :ostype
        attribute :storage
        attribute :template
        attribute :arch
        attribute :memory
        attribute :swap
        attribute :hostname
        attribute :nameserver
        attribute :searchdomain
        attribute :password
        attribute :onboot
        attribute :startup
        attribute :rootfs
        attribute :cores
        attribute :cpuunits
        attribute :cpulimit
        attribute :description
        attribute :console
        attribute :cmode
        attribute :tty
        attribute :force
        attribute :lock
        attribute :pool
        attribute :bwlimit
        attribute :unprivileged
        attribute :interfaces
        attribute :mount_points

        def initialize(attributes = {})
          prepare_service_value(attributes)
          initialize_interfaces(attributes)
          initialize_mount_points(attributes)
          super(attributes)
        end

        attr_reader :interfaces

        attr_reader :mount_points

        def mac_addresses
          Fog::Proxmox::NicHelper.to_mac_adresses_array(interfaces)
        end

        def type_console
          'vnc' # by default. term is available too
        end

        private

        def initialize_interfaces(attributes)
          nets = Fog::Proxmox::NicHelper.collect_nics(attributes)
          @interfaces ||= Fog::Compute::Proxmox::Interfaces.new
          nets.each do |key, value|
            nic_hash = {
              id: key.to_s,
              name: Fog::Proxmox::NicHelper.extract_name(value),
              mac: Fog::Proxmox::NicHelper.extract_mac_address(value)
            }
            names = Fog::Compute::Proxmox::Interface.attributes.reject { |key, _value| %i[id mac name].include? key }
            names.each { |name| nic_hash.store(name.to_sym, Fog::Proxmox::ControllerHelper.extract(name, value)) }
            @interfaces << Fog::Compute::Proxmox::Interface.new(nic_hash)
          end
        end

        def initialize_mount_points(attributes)
          controllers = Fog::Proxmox::ControllerHelper.collect_controllers(attributes)
          @mount_points ||= Fog::Compute::Proxmox::Disks.new
          controllers.each do |key, value|
            storage, volid, size = Fog::Proxmox::DiskHelper.extract_storage_volid_size(value)
            disk_hash = {
              id: key.to_s,
              storage: storage,
              volid: volid,
              size: size
            }
            names = Fog::Compute::Proxmox::Disk.attributes.reject { |key, _value| %i[id size storage volid].include? key }
            names.each { |name| disk_hash.store(name.to_sym, Fog::Proxmox::ControllerHelper.extract(name, value)) }
            @mount_points << Fog::Compute::Proxmox::Disk.new(disk_hash)
          end
        end
      end
    end
  end
end
