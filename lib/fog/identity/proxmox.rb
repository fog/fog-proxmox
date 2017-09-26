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
