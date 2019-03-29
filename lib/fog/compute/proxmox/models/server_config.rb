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
      # ServerConfig model
      class ServerConfig < Fog::Model
        identity  :vmid
        attribute :description
        attribute :ostype
        attribute :smbios1
        attribute :numa
        attribute :kvm
        attribute :vcpus
        attribute :cores
        attribute :bootdisk
        attribute :onboot
        attribute :boot
        attribute :agent
        attribute :scsihw
        attribute :sockets
        attribute :memory
        attribute :min_memory
        attribute :shares
        attribute :balloon
        attribute :name
        attribute :cpu
        attribute :cpulimit
        attribute :cpuunits
        attribute :keyboard
        attribute :vga
        attribute :interfaces
        attribute :disks

        def initialize(attributes = {})
          prepare_service_value(attributes)
          initialize_interfaces(attributes)
          initialize_disks(attributes)
          super(attributes)
        end

        def mac_addresses
          Fog::Proxmox::NicHelper.to_mac_adresses_array(interfaces)
        end

        attr_reader :disks
        attr_reader :interfaces

        def type_console
          console = 'vnc' if %w[std cirrus vmware].include?(vga)
          console = 'spice' if %w[qxl qxl2 qxl3 qxl4].include?(vga)
          console = 'term' if %w[serial0 serial1 serial2 serial3].include?(vga)
          console
        end

        private

        def initialize_interfaces(attributes)
          nets = Fog::Proxmox::NicHelper.collect_nics(attributes)
          @interfaces ||= Fog::Compute::Proxmox::Interfaces.new
          nets.each do |key, value|
            nic_hash = {
              id: key.to_s,
              model: Fog::Proxmox::NicHelper.extract_model(value),
              mac: Fog::Proxmox::NicHelper.extract_mac_address(value)
            }
            names = Fog::Compute::Proxmox::Interface.attributes.reject { |key, _value| %i[id mac model].include? key }
            names.each { |name| nic_hash.store(name.to_sym, Fog::Proxmox::ControllerHelper.extract(name, value)) }
            @interfaces << Fog::Compute::Proxmox::Interface.new(nic_hash)
          end
        end

        def initialize_disks(attributes)
          controllers = Fog::Proxmox::ControllerHelper.collect_controllers(attributes)
          @disks ||= Fog::Compute::Proxmox::Disks.new
          controllers.each do |key, value|
            storage, volid, size = Fog::Proxmox::DiskHelper.extract_storage_volid_size(value)
            disk_hash = {
              id: key.to_s,
              size: size,
              volid: volid,
              storage: storage
            }
            names = Fog::Compute::Proxmox::Disk.attributes.reject { |key, _value| %i[id size storage volid].include? key }
            names.each { |name| disk_hash.store(name.to_sym, Fog::Proxmox::ControllerHelper.extract(name, value)) }
            @disks << Fog::Compute::Proxmox::Disk.new(disk_hash)
          end
        end
      end
    end
  end
end
