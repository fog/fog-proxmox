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

require 'fog/compute/models/server'

module Fog
  module Compute
    class Proxmox
      # Server model
      class Server < Fog::Compute::Server
        identity  :vmid
        attribute :acpi
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
        attribute :hostcpi
        attribute :hotplug
        attribute :hugepages
        attribute :ide
        attribute :keyboard
        attribute :kvm
        attribute :localtime
        attribute :lock
        attribute :machine
        attribute :memory
        attribute :migrate_downtime
        attribute :migrate_speed
        attribute :name
        attribute :network
        attribute :node
        attribute :numa
        attribute :onboot
        attribute :ostype
        # not recommended
        # attribute :parallel
        attribute :pool
        attribute :protection
        attribute :reboot
        attribute :sata
        attribute :scsi
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
        attribute :virtio
        attribute :watchdog
        def initialize(attributes = {})
          super
        end
        
        def create
          service.create_server(attributes)
        end

        def destroy
          requires :realm
          service.delete_server(attributes)
          true
        end
      end
    end
  end
end
