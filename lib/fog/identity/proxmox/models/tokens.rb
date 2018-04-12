# Copyright 2018 Tristan Robert  

# This file is part of Fog::Proxmox.

# Fog::Proxmox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Fog::Proxmox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Fog::Proxmox. If not, see <http://www.gnu.org/licenses/>.

require 'fog/proxmox/models/collection'
require 'fog/identity/proxmox/models/token'

module Fog
  module Identity
    class Proxmox
        class Tokens < Fog::Proxmox::Collection
          model Fog::Identity::Proxmox::Token

          def add(response)
            Fog::Identity::Proxmox::Token.new(
              :user => {:name => get(response,'username'),:password => get(response,'password')}, :value => get(response,'ticket'), :csrf => get(response,'CSRFPreventionToken')
            )
          end

          def authenticate(auth)
            response = service.token_authenticate(auth)
            add(response)
          end

          def validate(subject_token)
            response = service.token_validate(subject_token)
            add(response)        
          end

          def check(subject_token)
            service.token_check(subject_token)
            true
          end

          def revoke(subject_token)
            service.token_revoke(subject_token)
            true
          end
        end
    end
  end
end