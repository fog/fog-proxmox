require 'fog/proxmox/models/compute/server'

module Fog
    module Compute
        class Proxmox
            class Servers < Fog::Collection
                model Fog::Compute::Proxmox::Server
            end
        end
    end
end
