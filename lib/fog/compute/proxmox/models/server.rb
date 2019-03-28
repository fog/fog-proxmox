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
require 'fog/proxmox/helpers/disk_helper'
require 'fog/proxmox/hash'

module Fog
  module Compute
    class Proxmox
      # Server model
      class Server < Fog::Compute::Server
        identity  :vmid
        attribute :node_id
        attribute :config
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
        attribute :blockstat
        attribute :balloon
        attribute :ballooninfo
        attribute :snapshots
        attribute :template
        attribute :tasks
        attribute :vmgenid

        def initialize(attributes = {})
          prepare_service_value(attributes)
          initialize_config(attributes)
          super(attributes)
        end

        def type
          attributes[:type]
        end 

        def node
          attributes[:node] = node_id.nil? ? nil : begin
            Fog::Compute::Proxmox::Node.new(service: service,
                                             node: node_id)
          end
        end 

        # request with async task
        def request(name, body_params = {}, path_params = {})
          requires :node_id, :type
          path = path_params.merge(node: node_id, type: type)
          task_upid = service.send(name, path, body_params)
          tasks.wait_for(task_upid)
        end

        def create(attributes = {})
          request(:create_server, attributes.merge(vmid: vmid))
        end

        def update(attributes = {})
          requires :vmid
          request(:update_server, attributes, vmid: vmid)
        end

        def destroy(options = {})
          requires :vmid
          request(:delete_server, options, vmid: vmid)
        end

        def action(action, options = {})
          requires :vmid
          action_known = %w[start stop resume suspend shutdown reset].include? action
          message = "Action #{action} not implemented"
          raise Fog::Errors::Error, message unless action_known
          request(:action_server, options, action: action, vmid: vmid)
        end

        def ready?
          status == 'running'
        end

        def reload
          requires :vmid
          object = collection.get(vmid)
          merge_attributes(object.attributes)
        end

        def backup(options = {})
          requires :vmid
          request(:create_backup, options.merge(vmid: vmid))
        end

        def restore(backup, options = {})
          requires :vmid
          config = options.merge(archive: backup.volid, force: 1)
          create(config)
        end

        def clone(newid, options = {})
          requires :vmid
          request(:clone_server, options.merge(newid: newid), vmid: vmid)
        end

        def create_template(options = {})
          requires :vmid, :node_id
          service.template_server({ node: node_id, type: type, vmid: vmid }, options)
        end

        def migrate(target, options = {})
          requires :vmid
          request(:migrate_server, options.merge(target: target), vmid: vmid)
        end

        def extend(disk, size, options = {})
          requires :vmid, :node_id
          service.resize_server({ node: node_id, vmid: vmid }, options.merge(disk: disk, size: size))
        end

        def move(disk, storage, options = {})
          requires :vmid
          request(:move_disk, options.merge(disk: disk, storage: storage), vmid: vmid)
        end

        def attach(disk, options = {})
          config = Fog::Proxmox::DiskHelper.flatten(disk.merge(options: options))
          update(config)
        end

        def detach(diskid)
          update(delete: diskid)
        end

        def config
          requires :node_id, :vmid, :type
          path_params = { node: node_id, type: type, vmid: vmid }
          attributes[:config] = vmid.nil? ? nil : begin
            Fog::Compute::Proxmox::ServerConfig.new({ service: service, vmid: vmid }.merge(service.get_server_config(path_params)))
          end
        end

        def snapshots
          attributes[:snapshots] ||= vmid.nil? ? [] : begin
            Fog::Compute::Proxmox::Snapshots.new(service: service, server_id: vmid, server_type: type, node_id: node_id)
          end
        end

        def backups
          list 'backup'
        end

        def images
          list 'images'
        end

        def list(content)
          storages = node.storages.list_by_content_type content
          volumes = []
          storages.each { |storage| volumes += storage.volumes.list_by_content_type_and_by_server(content, vmid) }
          volumes
        end

        def tasks
          attributes[:tasks] ||= vmid.nil? ? [] : begin
            Fog::Compute::Proxmox::Tasks.new(service: service,
              node_id: node_id).select { |task| task.id == vmid }
          end
        end

        def start_console(options = {})
          raise ::Fog::Proxmox::Errors::ServiceError, "Unable to start console because server not running." unless ready?
          type_console = config.type_console
          raise ::Fog::Proxmox::Errors::ServiceError, "Unable to start console because VGA display server config is not set or unknown." unless type_console
          requires :vmid, :node_id, :type
          path_params = { node: node_id, type: type, vmid: vmid }
          body_params = options
          data = service.send(('create_' + type_console).to_sym, path_params, body_params)
          task_upid = data['upid']
          if task_upid
            task = tasks.get(task_upid)
            task.wait_for { running? }
          end
          data
        end

        def connect_vnc(options = {})
          requires :vmid, :node_id, :type
          path_params = { node: node_id, type: type, vmid: vmid }
          query_params = { port: options['port'], vncticket: options['ticket'] }
          service.get_vnc(path_params, query_params)
        end

        protected 

        def initialize_config(attributes = {})
          attributes[:config] = vmid.nil? ? nil : begin
            Fog::Compute::Proxmox::ServerConfig.new(service: service, vmid: vmid)
          end
        end

        private

        def node
          node_id.nil? ? nil : begin
            Fog::Compute::Proxmox::Node.new(service: service,
                                             node: node_id)
          end
        end 
      end
    end
  end
end
