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
