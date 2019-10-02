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

# frozen_string_literal: true

require 'fog/core'

module Fog
  module Proxmox
    # Identity and authentication proxmox class
    class Identity < Fog::Service
      requires :pve_url
      recognizes(
        :pve_ticket,
        :pve_path,
        :pve_ticket_expires,
        :pve_csrftoken,
        :persistent,
        :current_user,
        :pve_username,
        :pve_password,
        :pve_deadline
      )

      model_path 'fog/identity/proxmox/models'
      model :principal
      model :user
      collection :users
      model :group
      collection :groups
      model :pool
      collection :pools
      model :role
      collection :roles
      model :domain
      model :domain_type
      collection :domains
      model :permission
      collection :permissions

      request_path 'fog/identity/proxmox/requests'

      # Manage permissions
      request :check_permissions
      request :list_permissions
      request :update_permissions
      request :read_version

      # Manage users
      request :list_users
      request :get_user
      request :create_user
      request :update_user
      request :delete_user
      request :change_password

      # CRUD groups
      request :list_groups
      request :get_group
      request :create_group
      request :update_group
      request :delete_group

      # CRUD roles
      request :list_roles
      request :get_role
      request :create_role
      request :update_role
      request :delete_role

      # CRUD domains
      request :list_domains
      request :get_domain
      request :create_domain
      request :update_domain
      request :delete_domain

      # CRUD pools
      request :list_pools
      request :get_pool
      request :create_pool
      request :update_pool
      request :delete_pool

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
          @path_prefix = URI.parse(options[:pve_url]).path
          authenticate
          @persistent = options[:persistent] || false
          url = "#{@scheme}://#{@host}:#{@port}"
          @connection = Fog::Core::Connection.new(
            url,
            @persistent,
            @connection_options.merge(path_prefix: @path_prefix)
          )
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
