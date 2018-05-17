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

require 'fog/proxmox/core'

module Fog
  module Compute
    # Proxmox compute service
    class Proxmox < Fog::Service
      requires :pve_url
      recognizes :pve_ticket, :pve_path, :pve_ticket_expires,
                 :pve_csrftoken, :persistent, :current_user, :pve_username,
                 :pve_password, :pve_deadline

      # Models
      model_path 'fog/compute/proxmox/models'
      model :node
      collection :nodes
      model :server
      collection :servers
      model :server_config
      collection :server_configs
      model :volume
      collection :volumes
      model :storage
      collection :storages
      model :task
      collection :tasks
      model :snapshot
      collection :snapshots

      # Requests
      request_path 'fog/compute/proxmox/requests'

      # Manage nodes cluster
      request :list_nodes
      request :get_node
      # Manage servers
      request :next_vmid
      request :check_vmid
      request :list_servers
      request :create_server
      request :get_server_status
      request :list_server_configs
      request :update_server
      request :delete_server
      request :action_server
      request :template_server
      request :clone_server
      request :migrate_server
      request :move_disk
      request :resize
      # Manage volumes
      request :list_volumes
      request :get_volume
      request :delete_volume
      # Manage backups
      request :create_backup
      # Manage storages
      request :list_storages
      request :get_storage
      # Tasks
      request :list_tasks
      request :get_task
      request :stop_task
      request :status_task
      request :log_task
      # CRUD snapshots
      request :list_snapshots
      request :get_snapshot
      request :create_snapshot
      request :update_snapshot
      request :delete_snapshot
      request :rollback_snapshot

      # Mock class
      class Mock
        attr_reader :config

        def initialize(options = {})
          @pve_uri = URI.parse(options[:pve_url])
          @pve_path = @pve_uri.path
          @config = options
        end
      end

      # Real class
      class Real
        include Fog::Proxmox::Core
        def initialize(options = {})
          initialize_identity(options)
          @connection_options = options[:connection_options] || {}
          authenticate
          @persistent = options[:persistent] || false
          url = "#{@scheme}://#{@host}:#{@port}"
          @connection = Fog::Core::Connection.new(url, @persistent, @connection_options)
        end

        def config
          self
        end

        def configure(source)
          source.instance_variables.each do |v|
            instance_variable_set(v, source.instance_variable_get(v))
          end
        end
      end
    end
  end
end
