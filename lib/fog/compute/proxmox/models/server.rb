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
require 'fog/proxmox/disk'
require 'fog/proxmox/hash'
require 'fog/proxmox/mac_address'

module Fog
  module Compute
    class Proxmox
      # Server model
      class Server < Fog::Compute::Server
        identity  :vmid
        attribute :node
        attribute :config
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
        attribute :snapshots
        attribute :tasks
        attribute :type

        def to_s
          vmid.to_s
        end

        def initialize(attributes = {})
          self.type = 'qemu'
          prepare_service_value(attributes)
          super
        end

        def create(config = {})
          requires :node
          path_params = { node: node, type: type }
          body_params = config.merge(vmid: vmid)
          task_upid = service.create_server(path_params, body_params)
          task_wait_for(task_upid)
        end

        def restore(backup, options = {})
          requires :node, :vmid
          path_params = { node: node, type: type }
          body_params = options.merge(vmid: vmid, archive: backup.volid, force: 1)
          task_upid = service.create_server(path_params, body_params)
          task_wait_for(task_upid)
        end

        def update(config = {})
          requires :node, :vmid
          path_params = { node: node, type: type, vmid: vmid }
          body_params = config
          task_upid = service.update_server(path_params, body_params)
          task_wait_for(task_upid)
        end

        def destroy(options = {})
          requires :vmid, :node
          path_params = { node: node, type: type, vmid: vmid }
          body_params = options
          task_upid = service.delete_server(path_params, body_params)
          task_wait_for(task_upid)
        end

        def action(action, options = {})
          requires :vmid, :node
          raise Fog::Errors::Error, "Action #{action} not implemented" unless %w[start stop resume suspend shutdown reset].include? action
          path_params = { node: node, type: type, action: action, vmid: vmid }
          body_params = options
          task_upid = service.action_server(path_params, body_params)
          task_wait_for(task_upid)
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
          requires :vmid, :node
          task_upid = service.create_backup(node, options.merge(vmid: vmid))
          task_wait_for(task_upid)
        end

        def clone(newid, options = {})
          requires :vmid, :node
          path_params = { node: node, type: type, vmid: vmid }
          body_params = options.merge(newid: newid)
          task_upid = service.clone_server(path_params, body_params)
          task_wait_for(task_upid)
        end

        def template(options = {})
          requires :vmid, :node
          path_params = { node: node, type: type, vmid: vmid }
          body_params = options
          service.template_server(path_params, body_params)
        end

        def migrate(target, options = {})
          requires :vmid, :node
          path_params = { node: node, type: type, vmid: vmid }
          body_params = options.merge(target: target)
          task_upid = service.migrate_server(path_params, body_params)
          task_wait_for(task_upid)
        end

        def extend(disk, size, options = {})
          requires :vmid, :node
          path_params = { node: node, vmid: vmid }
          body_params = options.merge(disk: disk, size: size)
          service.resize_server(path_params, body_params)
        end

        def move(disk, storage, options = {})
          requires :vmid, :node
          path_params = { node: node, vmid: vmid }
          body_params = options.merge(disk: disk, storage: storage)
          task_upid = service.move_disk(path_params, body_params)
          task_wait_for(task_upid)
        end

        def attach(disk, options = {})
          options_to_s = Fog::Proxmox::Hash.stringify(options)
          config = Fog::Proxmox::Disk.flatten(disk, options_to_s)
          update(config)
        end

        def detach(diskid)
          update(delete: diskid)
        end

        def snapshots
          @snapshots ||= begin
            Fog::Compute::Proxmox::Snapshots.new(service: service,
                                                 server: self)
          end
        end

        def config
          @config = begin
            path_params = { node: node, type: type, vmid: vmid }
            data = service.get_server_config path_params
            Fog::Compute::Proxmox::ServerConfig.new({ service: service,
                                                      server: self }.merge(data))
          end
        end

        def backups
          volumes 'backup'
        end

        def disk_images
          volumes 'images'
        end

        def volumes(content)
          storages = node.storages.list_by_content_type content
          volumes = []
          storages.each { |storage| volumes += storage.volumes.list_by_content_type_and_by_server(content, vmid) }
          volumes
        end

        def tasks
          node.tasks.search(vmid: vmid)
        end

        def task_wait_for(task_upid)
          task = tasks.get task_upid
          task.wait_for { finished? }
          task.succeeded?
        end

        def mac_addresses
          addresses = []
          config.nics.each { |_key, value| addresses.push(Fog::Proxmox::MacAddress.extract(value)) }
          addresses
        end
      end
    end
  end
end
