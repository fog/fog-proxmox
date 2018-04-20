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
require 'fog/identity/proxmox/models/domain'

module Fog
  module Identity
    class Proxmox
        class Domains < Fog::Proxmox::Collection
          model Fog::Identity::Proxmox::Domain

          def to_domain(hash)
            realm = hash['realm']
            type_value = hash['type']
            type_hash = hash.reject {|k,v| ['realm','type'].include? k}
            type = to_type(type_value,type_hash)
            new({:realm => realm, :type => type})
          end

          def all(options = {})
            load_response(service.list_domains, 'domains')
          end

          def find_by_id(id)
            response = service.get_domain(id)
            body = JSON.decode(response.body)
            data = body['data']
            data.store('realm',id)
            data.delete_if {|k,v| k == 'digest'}
            to_domain(data)
          end

          def destroy(id)
            domain = find_by_id(id)
            domain.destroy
          end

          def create(attributes = {})
            domain = new(attributes.slice(:realm))
            type_s = attributes[:type]
            attr = attributes.reject {|k,v| [:realm,:type].include? k}
            domain.type = to_type(type_s,attr)
            domain.create
          end

          def to_type(type,attributes)
            type_class(type).new(attributes)
          end

          def type_class(type)
            if type == 'pam' 
              type_class = Fog::Identity::Proxmox::Pam
            elsif type == 'pve' 
              type_class = Fog::Identity::Proxmox::Pve
            elsif type == 'ldap' 
              type_class = Fog::Identity::Proxmox::Ldap
            elsif type == 'ad' 
              type_class = Fog::Identity::Proxmox::Activedirectory
            else
              raise Fog::Proxmox::Errors::NotFound.new('domain type unknown')
            end
            type_class
          end

        end
    end
  end
end