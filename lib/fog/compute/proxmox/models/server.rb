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
require 'fog/proxmox/hash'

module Fog
  module Compute
    class Proxmox
      # Server model
      class Server < Fog::Compute::Server
        identity  :vmid
        attribute :node
        attribute :id
        attribute :name
        attribute :type
        attribute :maxdisk
        attribute :disk
        attribute :diskwrite
        attribute :diskread
        attribute :uptime
        attribute :netout
        attribute :netin
        attribute :cpu
        attribute :cpus
        attribute :template
        attribute :status
        attribute :maxcpu
        attribute :mem
        attribute :maxmem
        attribute :qmpstatus
        attribute :ha
        attribute :pid
        attribute :nics
        attribute :blockstat
        attribute :balloon
        attribute :ballooninfo

        def initialize(attributes = {})
          prepare_service_value(attributes)
          super
        end

        def create(config = {})
          requires :node
          config.store(:vmid, vmid)
          task_upid = service.create_server(node, config)
          task_upid
        end

        def update(config = {})
          requires :node, :vmid
          task_upid = service.update_server(node, vmid, config)
          task_upid
        end

        def attach_volume(volume,options = {})
          options_to_s = Fog::Proxmox::Hash.stringify(options)
          config = { "#{volume[:id]}": "#{volume[:storage]}:#{volume[:size]},#{options_to_s}" }
          update(config)
        end

        def detach_volume(volume)
          options = { delete: "#{volume[:id]}" }
          update(options)
        end

        def destroy(options = {})
          requires :vmid, :node
          task_upid = service.delete_server(node, vmid, options)
          task_upid
        end

        def action(action, options = {})
          requires :vmid, :node
          raise Fog::Errors::Error, "Action #{action} not implemented" unless %w[start stop resume suspend shutdown reset].include? action
          task_upid = service.action_server(action, node, vmid, options)
          task_upid
        end

        def ready?
          status == 'running'
        end

        def reload   
          requires :vmid, :node    
          object = collection.get(node,vmid)     
          merge_attributes(object.attributes)
        end

        def backup(options = {})
          requires :vmid, :node
          task_upid = service.backup(node, options.merge({ vmid: vmid }))
          task_upid
        end

        def clone(newid, options = {})
          requires :vmid, :node
          task_upid = service.clone_server(node, vmid, options.merge({ newid: newid }))
          task_upid
        end

        def template(options = {})
          requires :vmid, :node
          task_upid = service.template_server(node, vmid, options)
          task_upid
        end

        def migrate(target, options = {})
          requires :vmid, :node
          task_upid = service.migrate_server(node, vmid, options.merge({ target: target }))
          task_upid
        end

      end
    end
  end
end
