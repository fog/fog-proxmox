# frozen_string_literal: true

module Fog
  module Compute
    module Proxmox
      # Disk type class
      class DiskType
        include Enumerable

        def each
          (0..3).each do |i|
            yield 'ide' + i
          end
          (0..13).each do |i|
            yield 'scsi' + i
          end
          (0..15).each do |i|
            yield 'virtio' + i
          end
          (0..5).each do |i|
            yield 'sata' + i
          end
          yield 'efidisk0'
        end
      end
    end
  end
end
