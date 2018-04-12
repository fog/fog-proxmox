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

  #Identity module
  module Identity
    autoload :Proxmox, File.expand_path('../identity/proxmox', __FILE__)
  end
  # Compute module
  module Compute
    autoload :Proxmox, File.expand_path('../compute/proxmox', __FILE__)
  end
  # Storage module
  module Storage
    autoload :Proxmox, File.expand_path('../storage/proxmox', __FILE__)
  end
  # Network module
  module Network
    autoload :Proxmox, File.expand_path('../network/proxmox', __FILE__)
  end

  # Proxmox module
  module Proxmox
    extend Fog::Provider
    service(:identity, 'Identity')
    service(:compute, 'Compute')
    service(:storage, 'Storage')
    service(:network, 'Network')

    @token_cache = {}

    # Default lifetime token is 2 hours
    @token_lifetime = 3600

    class << self
      attr_accessor :token_cache
    end

    def self.clear_token_cache
      Fog::Proxmox.token_cache = {}
    end

    def self.authenticate(options, connection_options = {})
      
      username, body = retrieve_tokens(options, connection_options)
      return {
        :user   => {:name => username, :token_cache => @token_cache},
        :ticket => body['data']['ticket'],
        :csrftoken => body['data']['CSRFPreventionToken']
      }
    end

    def self.retrieve_tokens(options, connection_options = {})

      username          = options[:proxmox_username].to_s
      password          = options[:proxmox_password].to_s
      auth_token        = options[:proxmox_auth_token]
      url               = options[:proxmox_url]

      uri = URI.parse(url)

      connection = Fog::Core::Connection.new(uri.to_s, false, connection_options)

      response, expires = Fog::Proxmox.token_cache[{:user => username}] if @token_lifetime > 0

      unless response && expires > Time.now
        request = {
          :expects  => [200, 204],
          :headers  => {'Accept' => 'application/json'},
          :body     => "username=#{username}&password=#{password}",
          :method   => 'POST',
          :path     =>  'api2/json/access/ticket',
        }

        response = connection.request(request)

        if @token_lifetime > 0
          cache = Fog::Proxmox.token_cache
          cache[{:user => username}] = response, Time.now + @token_lifetime
          Fog::Proxmox.token_cache = cache
        end
      end

      [username, Fog::JSON.decode(response.body)]
    end

    def self.get_version(uri, auth_token, connection_options = {})
      version_cache = "#{uri}"
      return @version[version_cache] if @version && @version[version_cache]
      connection = Fog::Core::Connection.new("#{uri.scheme}://#{uri.host}:#{uri.port}", false, connection_options)
      response = connection.request(
        :expects => [200, 204, 300],
        :headers  => {'Accept' => 'application/json'},
        :cookies => [{'PVEAuthCookie'=> auth_token}],
        :method  => 'GET',
        :path    => 'api2/json/version'
      )

      body = Fog::JSON.decode(response.body)

      @version                = {} unless @version
      @version[version_cache] = extract_version_from_body(body)
    end

    def self.extract_version_from_body(body)
      return nil if body['version'].empty?
      version = body['version']
      version
    end

  end
end
