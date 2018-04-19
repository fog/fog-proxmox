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
  module Identity
    # Identity and authentication proxmox class
    class Proxmox < Fog::Service
      requires :proxmox_url, :proxmox_path
      recognizes :proxmox_ticket, :proxmox_ticket_expires, :proxmox_csrftoken, :persistent, :current_user, :proxmox_username, :proxmox_password

      model_path 'fog/identity/proxmox/models'
      model :user
      collection :users
      model :group
      collection :groups
      request_path 'fog/identity/proxmox/requests'
      request :get_version
      request :list_users
      request :get_user
      request :create_user
      request :update_user
      request :delete_user
      request :list_groups
      request :get_group
      request :create_group
      request :update_group
      request :delete_group

      # Mock class
      class Mock
        attr_reader :config

        def initialize(options = {})
          @proxmox_uri = URI.parse(options[:proxmox_url])
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
          @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
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