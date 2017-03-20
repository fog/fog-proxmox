module Fog
    module Compute
        class Proxmox < Fog::Service
            model_path 'fog/proxmox/models/compute'
            model :node
            collection :nodes
            model :server
            collection :servers
            model :pool
            collection :pools
        end
    end
end

