module Fog
  module Identity
    class Proxmox
        class Tokens < Fog::Core::Collection
          model Fog::Identity::Proxmox:Token

          def authenticate(auth)
            response = service.token_authenticate(auth)
            Fog::Identity::Proxmox::Token.new(:user => {:name => response.body['username']}, 
            :value => response.body['ticket'], :csrf => response.body['CSRFPreventionToken'])
            )
          end
        end
      end
    end
  end
end