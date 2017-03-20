module Fog
    module Compute
        class Proxmox
            class Node < Fog::Model
                # required
                attribute :name, :aliases => "node"
            end
        end
    end
end