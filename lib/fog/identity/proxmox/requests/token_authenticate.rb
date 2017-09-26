module Fog
    module Identity
      class Proxmox
          class Real
            def token_authenticate(auth)
              response = request(
                :expects => [200],
                :method  => 'POST',
                :path    => "access/ticket",
                :body    => Fog::JSON.encode(auth)
              )
            end
          end
  
          class Mock
          end
        end
    end
end