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

require 'fog/proxmox/core'

module Fog
  module Compute
    # Proxmox compute service
    class Proxmox < Fog::Service
      requires :proxmox_url
      recognizes :ticket, :csrf_token
      PROXMOX_COMPUTE_BASE_PATH = '/api2/json'

      # Models
      model_path 'fog/compute/proxmox/models'
      model :node
      collection :nodes
      model :server
      collection :servers

      # Requests
      request_path 'fog/compute/proxmox/requests'

      # CRUD
      request :create
      request :delete
      request :start
      request :stop
      request :shutdown
      request :suspend
      request :resume
      request :reset
      request :current

      # Mock class
      class Mock
        def initialize(options = {}); end
      end
      # Real class
      class Real
        def initialize(options = {})
          @connection_options = options[:connection_options] || {}
          authenticate
          @persistent = options[:persistent] || false
          @url = "#{@scheme}://#{@host}:#{@port}"
          @connection = Fog::Core::Connection.new(@url, @persistent, @connection_options)
        end
      end
    end
  end
end
