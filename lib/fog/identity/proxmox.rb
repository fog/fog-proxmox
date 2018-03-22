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
      requires :proxmox_auth_path
      recognizes :proxmox_auth_token, :proxmox_csrf_token, :ticket, :username,
                 :password
    end

    request_path 'fog/identity/proxmox/requests'
    request :token_authenticate

    # Mock class
    class Mock
      def initialize(options = {}); end
    end
    # Real class
    class Real
      include Fog::Proxmox::Core
      def initialize(options = {})
        @path = Fog.credentials[:proxmox_auth_path] || options[:proxmox_auth_path]
        @url = "#{@scheme}://#{@host}:#{@port}/#{@path}"
        @connection = Fog::Core::Connection.new(@url, @connection_options)
      end
    end
  end
end
