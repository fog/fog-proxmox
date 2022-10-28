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
    class Cluster
      # class Real get_vnc request
      class Real
        def list_resources(resource_type = nil)
          query = resource_type.nil? ? '' : "type=#{resource_type}"
          request(
            expects: [200],
            method: 'GET',
            path: 'cluster/resources',
            query: query || ''
          )
        end

        def list_qemu_resources
          list_resources('qemu')
        end

        def list_lxc_resources
          list_resources('lxc')
        end

        def list_storage_resources
          list_resources('storage')
        end
      end

      # class Mock get_vnc request
      class Mock
        def list_resources(resource_type)
          case resource_type
          when 'qemu'
            list_qemu_resources
          when 'lxc'
            list_lxc_resources
          when 'storage'
            list_storage_resources
          else
            (list_qemu_resources + list_lxc_resources + list_storage_resources)
          end
        end
        def list_qemu_resources
          [
            {
              'node' => 'pve',
              'type' => 'qemu',
              'vmid' => '100'
            }
          ]
        end

        def list_lxc_resources
          [
            {
              'node' => 'pve',
              'type' => 'lxc',
              'vmid' => '101'
            }
          ]
        end
        def list_storage_resources
          [
            {
              'node' => 'pve',
              'type' => 'storage',
              'storage' => 'local'
            },
            {
              'node' => 'pve',
              'type' => 'storage',
              'storage' => 'local'
            }
          ]
        end
      end
    end
  end
end
