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

module Fog
  module Identity
    class Proxmox
        class Tokens < Fog::Core::Collection
          model Fog::Identity::Proxmox:Token

          def authenticate(auth)
            response = service.token_authenticate(auth)
            Fog::Identity::Proxmox::Token.new(:user => {:name => response.body['username']}, :value => response.body['ticket'], :csrf => response.body['CSRFPreventionToken'])
          end
        end
    end
  end
end