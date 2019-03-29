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
      # class Domain model authentication
      class Domain < Fog::Model
        identity :realm
        attribute :comment
        attribute :tfa
        attribute :type

        def initialize(attributes = {})
          initialize_type(attributes)
          super(attributes)
        end

        def save(options = {})
          service.create_domain(type.attributes.merge(options).merge(realm: realm))
          reload
        end

        def destroy
          requires :realm
          service.delete_domain(realm)
          true
        end

        def update
          requires :realm
          service.update_domain(realm, type.attributes.merge(attributes.reject { |attribute| [:type].include? attribute }))
          reload
        end

        private

        def initialize_type(attributes = {})
          attributes[:type] ||= type.nil? ? nil : begin
            Fog::Proxmox::Identity::DomainType(type.attributes)
          end
        end

      end
    end
  end
end
