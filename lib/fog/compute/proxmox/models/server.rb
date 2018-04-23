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

# frozen_string_literal: true

require 'fog/compute/models/server'
require 'fog/storage/proxmox/models'
require 'fog/network/proxmox/models'

module Fog
  module Compute
    class Proxmox
      # Server model
      class Server < Fog::Compute::Server
        identity :id, aliases: 'vmid'
        attr_reader :acpi
        attribute :agent
        attribute :archive
        attribute :args
        attribute :autostart
        attribute :balloon
        attribute :bios
        attribute :boot
        attribute :bootdisk
        attribute :cdrom
        attribute :cores
        attribute :cpu
        attribute :cpulimit
        attribute :cpuunits
        attribute :description
        attribute :force
        attribute :freeze
        model Fog::Storage::Proxmox::Hostcpi
        attribute :hotplug
        attribute :hugepages
        model Fog::Storage::Proxmox::Ide
        attribute :keyboard
        attribute :kvm
        attribute :localtime
        attribute :lock
        attribute :machine
        attribute :memory
        attribute :migrate_downtime
        attribute :migrate_speed
        attribute :name
        model Fog::Compute::Proxmox::Network
        attribute :node
        attribute :numa
        model Fog::Compute::Proxmox::Numa
        attribute :onboot
        attribute :ostype
        # not recommended
        # model      Fog::Storage::Proxmox::Parallel
        attribute :pool
        attribute :protection
        attribute :reboot
        attribute :numa
        model      Fog::Storage::Proxmox::Sata
        model      Fog::Storage::Proxmox::Scsi
        attribute :shares
        attribute :smbios1
        attribute :smp
        attribute :sockets
        attribute :startdate
        attribute :startup
        attribute :storage
        attribute :tablet
        attribute :tdf
        attribute :template
        attribute :unique
        attribute :unused
        attribute :usb
        attribute :vcpus
        attribute :vga
        model Fog::Storage::Virtio
        attribute :watchdog
        def initialize(attributes = {})
          super
        end
      end
    end
  end
end
