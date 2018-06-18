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
        attribute :node
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

        def initialize(attributes = {})
          prepare_service_value(attributes)
          set_config(attributes)
          super
        end

        def type(attributes = {})
          @type ||= 'qemu' unless attributes[:type] || attributes['type']
          @type
        end

        def request(name, body_params = {}, path_params = {})
          requires :node, :type
          path = path_params.merge(node: node, type: type)
          task_upid = service.send(name, path, body_params)
          task_wait_for(task_upid)
        end

        def create(config = {})
          request(:create_server, config.merge(vmid: vmid))
        end

        def update(config = {})
          requires :vmid
          request(:update_server, config, vmid: vmid)
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

        def template(options = {})
          requires :vmid, :node
          service.template_server({ node: node, type: type, vmid: vmid }, options)
        end

        def migrate(target, options = {})
          requires :vmid
          request(:migrate_server, options.merge(target: target), vmid: vmid)
        end

        def extend(disk, size, options = {})
          requires :vmid, :node
          service.resize_server({ node: node, vmid: vmid }, options.merge(disk: disk, size: size))
        end

        def move(disk, storage, options = {})
          requires :vmid
          request(:move_disk, options.merge(disk: disk, storage: storage), vmid: vmid)
        end

        def attach(disk, options = {})
          options_to_s = Fog::Proxmox::Hash.stringify(options)
          config = Fog::Proxmox::DiskHelper.flatten(disk, options_to_s)
          update(config)
        end

        def detach(diskid)
          update(delete: diskid)
        end

        def set_config(attributes = {})
          @config = Fog::Compute::Proxmox::ServerConfig.new({ service: service }.merge(attributes))
        end

        def config
          path_params = { node: node, type: type, vmid: vmid }
          set_config(service.get_server_config(path_params)) if uptime
          @config
        end

        def snapshots
          @snapshots ||= begin
            Fog::Compute::Proxmox::Snapshots.new(service: service,
                                                 server: self)
          end
        end

        def backups
          volumes 'backup'
        end

        def images
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
      end
    end
  end
end
