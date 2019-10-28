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
require 'fog/proxmox/json'
require 'fog/core'
require 'fog/json'

module Fog
  # Proxmox module
  module Proxmox
    extend Fog::Provider
    autoload :Identity, File.expand_path('identity/proxmox', __dir__)
    autoload :Compute, File.expand_path('compute/proxmox', __dir__)
    autoload :Storage, File.expand_path('storage/proxmox', __dir__)
    autoload :Network, File.expand_path('network/proxmox', __dir__)
    service(:identity, 'Identity')
    service(:compute, 'Compute')
    service(:storage, 'Storage')
    service(:network, 'Network')

    @credentials = {}
    @now = Time.now

    # Default lifetime ticket is 2 hours
    @ticket_lifetime = 2 * 60 * 60

    class << self
      attr_reader :credentials
      attr_reader :version
      attr_accessor :now # tests only
    end

    def self.clear_credentials
      @credentials = {}
    end

    def self.authenticate(options, connection_options = {})
      get_tokens(options, connection_options)
      self
    end

    def self.authenticated?
      !@credentials.empty?
    end

    def self.credentials_has_expired?
      authenticated? && @credentials[:deadline] > @now
    end

    def self.extract_password(options)
      ticket = options[:pve_ticket]
      options[:pve_password] = ticket unless ticket
    end

    def self.get_tokens(options, connection_options = {})
      username          = options[:pve_username].to_s
      password          = options[:pve_password].to_s
      url               = options[:pve_url]
      extract_password(options)
      uri = URI.parse(url)
      @api_path = uri.path
      connection_options = connection_options.merge(path_prefix: @api_path)
      password = @credentials[:ticket] if credentials_has_expired?
      request_credentials(uri, connection_options, username, password) unless authenticated? && !credentials_has_expired?
    end

    def self.request_credentials(uri, connection_options, username, password)
      request = {
        expects: [200, 204],
        headers: { 'Accept' => 'application/json' },
        body: URI.encode_www_form(username: username, password: password),
        method: 'POST',
        path: 'access/ticket'
      }
      connection = Fog::Core::Connection.new(
        uri.to_s,
        false,
        connection_options
      )
      response  = connection.request(request)
      data      = Json.get_data(response)
      ticket    = data['ticket']
      username  = data['username']
      csrftoken = data['CSRFPreventionToken']
      deadline = Time.at(@now.to_i + @ticket_lifetime)
      save_token(username, ticket, csrftoken, deadline)
    end

    def self.save_token(username, ticket, csrftoken, deadline)
      @credentials = {
        username: username,
        ticket: ticket,
        csrftoken: csrftoken,
        deadline: deadline
      }
    end
  end
end
