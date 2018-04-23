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

    @token_cache = {}

    # Default lifetime ticket is 2 hours
    @ticket_lifetime = 2 * 60 * 60

    class << self
      attr_accessor :token_cache
      attr_reader :version
    end

    def self.clear_token_cache
      Fog::Proxmox.token_cache = {}
    end

    def self.authenticate(options, connection_options = {})
      get_tokens(options, connection_options)
      @token_cache
    end

    def self.set_password(options)
      ticket = options[:proxmox_ticket]
      options[:proxmox_password] = ticket unless ticket.nil?
    end

    def self.get_tokens(options, connection_options = {})
      username          = options[:proxmox_username].to_s
      password          = options[:proxmox_password].to_s
      ticket            = options[:proxmox_ticket]
      csrf_token        = options[:proxmox_csrftoken]
      ticket_deadline   = options[:proxmox_ticket_deadline]
      url               = options[:proxmox_url]

      set_password(options)

      uri = URI.parse(url)
      @api_path = uri.path
      @is_authenticated = !ticket.nil? && ticket_deadline > Time.now

      if @is_authenticated
        set_token_cache(username, ticket, csrf_token, ticket_deadline)
      else
        connection = Fog::Core::Connection.new(uri.to_s, false, connection_options)
        retrieve_tokens(connection, username, password)
      end
    end

    def self.retrieve_tokens(connection, username, password)
      request = {
        expects: [200, 204],
        headers: { 'Accept' => 'application/json' },
        body: "username=#{username}&password=#{password}",
        method: 'POST',
        path: "#{@api_path}/access/ticket"
      }

      response   = connection.request(request)
      body       = JSON.decode(response.body)
      data       = body['data']
      ticket     = data['ticket']
      username   = data['username']
      csrf_token = data['CSRFPreventionToken']

      now = Time.now
      ticket_deadline = Time.at(now.to_i + @ticket_lifetime)
      set_token_cache(username, ticket, csrf_token, ticket_deadline)
    end

    def self.set_token_cache(username, ticket, csrf_token, ticket_deadline)
      @token_cache = { username: username, ticket: ticket, csrf_token: csrf_token, ticket_deadline: ticket_deadline }
      Fog::Proxmox.token_cache = @token_cache
    end
  end
end
