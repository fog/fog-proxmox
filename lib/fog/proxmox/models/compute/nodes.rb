require 'fog/proxmox/models/compute/node'

module Fog
    module Compute
        class Proxmox
            class Nodes < Fog::Collection
                model Fog::Compute::Proxmox::Node
            end
        end
    end
end