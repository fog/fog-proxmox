require 'fog/proxmox/core'

module Fog
    module Compute
        class Proxmox < Fog::Service

            requires :proxmox_url
            recognizes :ticket, :csrf_token

            # Models
            model_path 'fog/compute/proxmox/models'
            model :node
            collection :nodes
            model :server
            collection :servers
            model :pool
            collection :pools

            # Requests
            request_path 'fog/compute/proxmox/requests'
            
            class Mock

            end

            class Real
               def initialize(options = {})
                  @connection_options = options[:connection_options] || {}
                  authenticate
                  @persistent = options[:persistent] || false
                  @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
               end
            end

        end
    end
end

