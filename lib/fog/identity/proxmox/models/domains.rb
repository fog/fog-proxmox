# frozen_string_literal: true

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
      # class Domains collection authentication
      class Domains < Fog::Proxmox::Collection
        model Fog::Identity::Proxmox::Domain

        def to_domain(hash)
          realm = hash['realm']
          type_value = hash['type']
          tfa_value = hash['tfa']
          type_hash = hash.reject { |k, _v| %w[realm type tfa].include? k }
          type = to_type(type_value, type_hash)
          tfa = to_tfa(tfa_value)
          type.tfa = tfa if tfa
          new(realm: realm, type: type)
        end

        def all(_options = {})
          load_response(service.list_domains, 'domains')
        end

        def find_by_id(id)
          response = service.get_domain(id)
          body = JSON.decode(response.body)
          data = body['data']
          data.store('realm', id)
          data.delete_if { |k, _v| k == 'digest' }
          to_domain(data)
        end

        def destroy(id)
          domain = find_by_id(id)
          domain.destroy
        end

        def create(attributes = {})
          domain = new({ realm: attributes[:realm] })
          type_s = attributes[:type]
          tfa_s = attributes[:tfa]
          attr = attributes.reject { |k, _v| %i[realm type tfa].include? k }
          domain.type = to_type(type_s, attr)
          tfa = to_tfa(tfa_s)
          domain.type.tfa = tfa if tfa
          domain.create
        end

        def to_type(type, attributes)
          type_class(type).new(attributes)
        end

        def to_tfa(tfa_s)
          oath_rxp = /type=oath,step=(?<step>\d+),digits=(?<digits>\d+)/
          yubico_rxp = /type=yubico,id=(?<id>\w+),key=(?<key>\w+),url=(?<url>.+)/
          if oath_rxp.match(tfa_s)
            attributes = oath_rxp.named_captures
            type = 'oath'
          elsif yubico_rxp.match(tfa_s)
            attributes = yubico_rxp.named_captures
            type = 'yubico'
          end
          tfa_class(type).new(attributes) if type && attributes
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
            raise Fog::Proxmox::Errors::NotFound, 'domain type unknown'
          end
          type_class
        end

        def tfa_class(tfa)
          if tfa == 'oath'
            tfa_class = Fog::Identity::Proxmox::Oath
          elsif tfa == 'yubico'
            tfa_class = Fog::Identity::Proxmox::Yubico
          else
            raise Fog::Proxmox::Errors::NotFound, 'domain tfa unknown'
          end
          tfa_class
        end
      end
    end
  end
end
