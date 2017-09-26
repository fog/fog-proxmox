
module Fog
  module Identity
    class Proxmox
        class Token < Fog::Core::Model
          attribute :value
          attribute :user
          attribute :csrf

          def to_s
            value
          end
        end
    end
  end
end