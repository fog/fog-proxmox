# frozen_string_literal: true

module Fog
  module Compute
    module Proxmox
      # Disk type class
      class DiskType
        include Enumerable
        def ide
          (0..3).each do |i|
            yield 'ide' + i
          end
        end

        def scsi
          (0..13).each do |i|
            yield 'scsi' + i
          end
        end

        def virtio
          (0..15).each do |i|
            yield 'virtio' + i
          end
        end

        def sata
          (0..5).each do |i|
            yield 'sata' + i
          end
        end

        def other
          yield 'efidisk0'
        end
      end
    end
  end
end
