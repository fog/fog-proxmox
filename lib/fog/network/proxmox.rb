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

module Fog
  module Network
    # Proxmox network service
    class Proxmox < Fog::Service
      requires :pve_url
      recognizes :pve_ticket, :pve_path, :pve_ticket_expires, :pve_csrftoken, :persistent, :current_user, :pve_username, :pve_password

      model_path 'fog/network/proxmox/models'
      model :node
      collection :nodes
      model :network
      collection :networks

      request_path 'fog/network/proxmox/requests'

      # Manage nodes cluster
      request :list_nodes
      request :get_node
      request :power_node

      # CRUD networks
      request :list_networks
      request :get_network
      request :create_network
      request :update_network
      request :delete_network

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
          @connection = Fog::Core::Connection.new(url, @persistent, @connection_options.merge(path_prefix: @path_prefix))
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
