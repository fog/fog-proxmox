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
