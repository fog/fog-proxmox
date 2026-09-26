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

require 'fog/proxmox/attributes'

module Fog
  module Proxmox
    class Compute
      # HaResource model: an entry of the cluster HA manager
      # https://pve.proxmox.com/pve-docs/api-viewer/index.html#/cluster/ha/resources
      class HaResource < Fog::Model
        identity  :sid
        attribute :type
        attribute :state
        attribute :group
        attribute :max_relocate
        attribute :max_restart
        attribute :comment
        attribute :digest

        def initialize(new_attributes = {})
          prepare_service_value(new_attributes)
          Fog::Proxmox::Attributes.set_attr_and_sym('sid', attributes, new_attributes)
          requires :sid
          super(new_attributes)
        end

        def save
          service.create_ha_resource(request_params)
        end

        def update
          # sid is passed in the path; type is create-only and rejected by PVE on update
          service.update_ha_resource({ sid: sid }, request_params.reject { |key, _value| %i[sid type].include?(key) })
        end

        def destroy
          service.delete_ha_resource(sid: sid)
        end

        private

        def request_params
          params = {
            sid: sid,
            type: type,
            group: group,
            state: state,
            max_relocate: max_relocate,
            max_restart: max_restart,
            comment: comment
          }
          params.reject { |_key, value| value.nil? }
        end
      end
    end
  end
end
