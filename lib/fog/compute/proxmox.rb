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
      model :pool
      collection :pools
      model :server
      collection :servers
      model :task
      collection :tasks

      # Requests
      request_path 'fog/compute/proxmox/requests'

      # CRUD pools
      request :list_pools
      request :get_pool
      request :create_pool
      request :update_pool
      request :delete_pool

      # Manage servers
      request :next_vmid
      request :check_vmid
      request :list_servers
      request :create_server
      request :get_server
      request :update_server
      request :delete_server
      request :action_server
      # Tasks
      request :list_tasks
      request :get_task
      request :stop_task
      request :status_task
      request :log_task

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
