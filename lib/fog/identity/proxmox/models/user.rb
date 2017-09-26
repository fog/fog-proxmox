module Fog
    module Identity
      class Proxmox
          class User < Fog::Core::Model
  
            attribute :name
            attribute :password
  
            def to_s
              name
            end
          end
      end
    end
  end