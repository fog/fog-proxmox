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
        identity  :vmid
        attribute :lock
        attribute :maxswap
        attribute :swap
        attribute :config

        def restore(backup, options = {})
          request(:create_server, options.merge(vmid: vmid, ostemplate: backup.volid, force: 1, restore: 1), vmid: vmid)
        end

        def move(volume, storage, options = {})
          request(:move_volume, options.merge(volume: volume, storage: storage), vmid: vmid)
        end

        def update(attributes = {})
          requires :vmid
          request(:update_server, attributes, vmid: vmid)
        end

        def config
          requires :node_id, :vmid, :type
          path_params = { node: node_id, type: type, vmid: vmid }
          attributes[:config] ||= vmid.nil? ? nil : begin
            Fog::Compute::Proxmox::ContainerConfig.new({ service: service, vmid: vmid }.merge(service.get_server_config(path_params)))
          end
        end

        def detach(mpid)
          update(delete: mpid)
        end

        def extend(disk, size, options = {})
          requires :vmid, :node_id
          path_params = { node: node_id, vmid: vmid }
          body_params = options.merge(disk: disk, size: size)
          task_upid = service.resize_container(path_params, body_params)
          tasks.wait_for(task_upid)
        end

        def action(action, options = {})
          raise Fog::Errors::Error, "Action #{action} not implemented" unless %w[start stop shutdown].include? action
          super
        end

        private

        def initialize_config(attributes = {})
          attributes[:config] ||= vmid.nil? ? nil : begin
            Fog::Compute::Proxmox::ContainerConfig.new({ service: service, vmid: vmid }.merge(attributes))
          end
        end
      end
    end
  end
end
