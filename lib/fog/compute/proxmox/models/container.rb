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

require 'fog/compute/proxmox/models/server'
require 'fog/compute/proxmox/models/container_config'

module Fog
  module Compute
    class Proxmox
      # Container model
      class Container < Fog::Compute::Proxmox::Server
        attribute :lock
        attribute :maxswap
        attribute :swap
        attribute :config

        def initialize(attributes = {})
          prepare_service_value(attributes)
          self.type = 'lxc'
          super
        end      

        def restore(backup, options = {})
          requires :node, :vmid
          path_params = { node: node, type: type }
          body_params = options.merge(vmid: vmid, ostemplate: backup.volid, force: 1, restore: 1)
          task_upid = service.create_server(path_params, body_params)
          task_wait_for(task_upid)
        end 

        def move(volume, storage, options = {})
          requires :vmid, :node
          path_params = { node: node, vmid: vmid }
          body_params = options.merge(volume: volume, storage: storage)
          task_upid = service.move_volume(path_params, body_params)
          task_wait_for(task_upid)
        end

        def update(config = {})
          requires :node, :vmid
          path_params = { node: node, type: type, vmid: vmid }
          body_params = config
          service.update_server(path_params, body_params)
        end       

        def config
          @config ||= begin
            path_params = { node: node, type: type, vmid: vmid }
            data = service.get_server_config path_params
            Fog::Compute::Proxmox::ContainerConfig.new({service: service,
                                                     container: self}.merge(data))
          end
        end

        def detach(mpid)
          update({ delete: mpid})
        end
        
        def extend(disk, size, options = {})
          requires :vmid, :node
          path_params = { node: node, vmid: vmid }
          body_params = options.merge(disk: disk, size: size)
          task_upid = service.resize_container(path_params, body_params)
          task_wait_for(task_upid)
        end

        def mac_addresses
          addresses = []
          config.nics.each { |_key,value| addresses.push(extract_mac_address(value)) }
          addresses
        end
        
      end
    end
  end
end
