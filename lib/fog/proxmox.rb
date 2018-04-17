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
    @token_lifetime = 2*60*60

    class << self
      attr_accessor :token_cache, :token_lifetime
      attr_reader :version
    end

    def self.clear_token_cache
      Fog::Proxmox.token_cache = {}
    end

    def self.authenticate(options, connection_options = {})
      
      ticket, token_expires, username, csrf_token = retrieve_tokens(options, connection_options)
      return {
        :user       => {:name => username, :token_cache => @token_cache},
        :ticket     => ticket,
        :csrftoken  => csrf_token,
        :expires    => token_expires
      }
    end

    def self.set_password(options)
      auth_token = options[:proxmox_auth_token]
      if auth_token!=nil
        options[:proxmox_password] = auth_token
      end
    end

    def self.retrieve_tokens(options, connection_options = {})

      username          = options[:proxmox_username].to_s
      password          = options[:proxmox_password].to_s
      auth_token        = options[:proxmox_auth_token]
      url               = options[:proxmox_url]
      path              = options[:proxmox_path]

      uri = URI.parse(url+path)

      set_password(options)

      connection = Fog::Core::Connection.new(uri.to_s, false, connection_options)

      unless @token_lifetime <= 0
        token_cache, expires = Fog::Proxmox.token_cache[{:user => username}]
      end

      now = Time.now

      unless token_cache && Time.now <= now
        if auth_token
          password = auth_token
        end
          request = {
            :expects  => [200, 204],
            :headers  => {'Accept' => 'application/json'},
            :body     => "username=#{username}&password=#{password}",
            :method   => 'POST',
            :path     =>  uri.path,
          }

        response   = connection.request(request)
        body       = JSON.decode(response.body)
        data       = body['data']
        ticket     = data['ticket']
        username   = data['username']
        csrf_token = data['CSRFPreventionToken']

        if @token_lifetime > 0
          cache                      = {}
          token_expires              = Time.at(now.to_i + @token_lifetime)
          cache[{:user => username}] = ticket, csrf_token, token_expires
          Fog::Proxmox.token_cache   = cache
        end
      end

      [ticket, token_expires, username, csrf_token]
    end
  end
end
