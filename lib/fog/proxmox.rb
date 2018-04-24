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

require 'fog/proxmox/version'
require 'fog/proxmox/core'
require 'fog/core'
require 'fog/json'

module Fog
  # Identity module
  module Identity
    autoload :Proxmox, File.expand_path('identity/proxmox', __dir__)
  end
  # Compute module
  module Compute
    autoload :Proxmox, File.expand_path('compute/proxmox', __dir__)
  end
  # Storage module
  module Storage
    autoload :Proxmox, File.expand_path('storage/proxmox', __dir__)
  end
  # Network module
  module Network
    autoload :Proxmox, File.expand_path('network/proxmox', __dir__)
  end

  # Proxmox module
  module Proxmox
    extend Fog::Provider
    service(:identity, 'Identity')
    service(:compute, 'Compute')
    service(:storage, 'Storage')
    service(:network, 'Network')

    @cache = {}

    # Default lifetime ticket is 2 hours
    @ticket_lifetime = 2 * 60 * 60

    class << self
      attr_accessor :cache
      attr_reader :version
    end

    def self.clear_cache
      Fog::Proxmox.cache = {}
    end

    def self.authenticate(options, connection_options = {})
      get_tokens(options, connection_options)
      @cache
    end

    def self.authenticated?
      !@cache.empty?
    end

    def self.extract_password(options)
      ticket = options[:pve_ticket]
      options[:pve_password] = ticket unless ticket
    end

    def self.get_tokens(options, _connection_options = {})
      username          = options[:pve_username].to_s
      password          = options[:pve_password].to_s
      url               = options[:pve_url]
      extract_password(options)
      uri = URI.parse(url)
      @api_path = uri.path
      retrieve_tokens(uri, _connection_options, username, password) unless authenticated?
    end

    def self.retrieve_tokens(uri, connection_options, username, password)
      request = {
        expects: [200, 204],
        headers: { 'Accept' => 'application/json' },
        body: "username=#{username}&password=#{password}",
        method: 'POST',
        path: "#{@api_path}/access/ticket"
      }

      connection = Fog::Core::Connection.new(
        uri.to_s,
        false,
        connection_options
      )

      response   = connection.request(request)
      body       = JSON.decode(response.body)
      data       = body['data']
      ticket     = data['ticket']
      username   = data['username']
      csrftoken = data['CSRFPreventionToken']

      now = Time.now
      deadline = Time.at(now.to_i + @ticket_lifetime)
      save_token(username, ticket, csrftoken, deadline)
    end

    def self.save_token(username, ticket, csrftoken, deadline)
      @cache = {
        username: username,
        ticket: ticket,
        csrftoken: csrftoken,
        deadline: deadline
      }
      Fog::Proxmox.cache = @cache
    end
  end
end
