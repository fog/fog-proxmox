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
require 'fog/proxmox/errors'

module Fog
  module Compute
    class Proxmox
      # Server model
      class Server < Fog::Compute::Server
        identity  :vmid
        attribute :digest
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

        def initialize(new_attributes = {})
          prepare_service_value(new_attributes)
          attributes[:node_id] = new_attributes[:node_id] unless new_attributes[:node_id].nil?
          attributes[:type] = new_attributes[:type] unless new_attributes[:type].nil?
          attributes[:vmid] = new_attributes[:vmid] unless new_attributes[:vmid].nil?
          attributes[:vmid] = new_attributes['vmid'] unless new_attributes['vmid'].nil?
          requires :node_id, :type, :vmid
          initialize_config(new_attributes)
          initialize_snapshots
          initialize_tasks
          super(new_attributes)
        end

        def persisted?
          service.next_vmid(vmid: vmid)
          true
        rescue Excon::Error::InternalServerError
          false
        rescue Excon::Error::BadRequest
          true
        end

        # request with async task
        def request(name, body_params = {}, path_params = {})
          requires :node_id, :type
          path = path_params.merge(node: node_id, type: type)
          task_upid = service.send(name, path, body_params)
          tasks.wait_for(task_upid)
        end

        def save(options = {})
          request(:create_server, options.merge(vmid: vmid))
          reload
        end

        def update(attributes = {})
          request(:update_server, attributes, vmid: vmid)
          reload
        end

        def destroy(options = {})
          request(:delete_server, options, vmid: vmid)
        end

        def action(action, options = {})
          action_known = %w[start stop resume suspend shutdown reset].include? action
          message = "Action #{action} not implemented"
          raise Fog::Errors::Error, message unless action_known
          request(:action_server, options, action: action, vmid: vmid)
          reload
        end

        def ready?
          status == 'running'
        end

        def backup(options = {})
          request(:create_backup, options.merge(vmid: vmid))
          reload
        end

        def restore(backup, options = {})
          attr_hash = options.merge(archive: backup.volid, force: 1)
          save(attr_hash)
        end

        def clone(newid, options = {})
          request(:clone_server, options.merge(newid: newid), vmid: vmid)
          reload
        end

        def create_template(options = {})
          service.template_server({ node: node_id, type: type, vmid: vmid }, options)
          reload
        end

        def migrate(target, options = {})
          request(:migrate_server, options.merge(target: target), vmid: vmid)
          reload
        end

        def extend(disk, size, options = {})
          service.resize_server({ node: node_id, vmid: vmid }, options.merge(disk: disk, size: size))
          reload
        end

        def move(disk, storage, options = {})
          request(:move_disk, options.merge(disk: disk, storage: storage), vmid: vmid)
          reload
        end

        def attach(disk, options = {})
          disk_hash = Fog::Proxmox::DiskHelper.flatten(disk.merge(options: options))
          update(disk_hash)
        end

        def detach(diskid)
          update(delete: diskid)
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
          path_params = { node: node_id, type: type, vmid: vmid }
          query_params = { port: options['port'], vncticket: options['ticket'] }
          service.get_vnc(path_params, query_params)
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
          storages.each { |storage| volumes += storage.volumes.list_by_content_type_and_by_server(content, identity) }
          volumes
        end

        protected 

        def initialize_config(new_attributes = {})
          options = { service: service, vmid: vmid }
          attributes[:config] = Fog::Compute::Proxmox::ServerConfig.new(options.merge(new_attributes))
        end

        private

        def initialize_snapshots
          attributes[:snapshots] = Fog::Compute::Proxmox::Snapshots.new(service: service, server_id: vmid, server_type: type, node_id: node_id)
        end

        def initialize_tasks
          attributes[:tasks] = Fog::Compute::Proxmox::Tasks.new(service: service, node_id: node_id).select { |task| task.id == vmid }
        end

        def node
          Fog::Compute::Proxmox::Node.new(service: service, node: node_id)
        end 
      end
    end
  end
end
