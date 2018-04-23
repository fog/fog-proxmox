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

# frozen_string_literal: true

require 'fog/core/model'

module Fog
  module Proxmox
    # class Model proxmox
    class Model < Fog::Model
      # Initialize a record
      def initialize(attributes)
        # Old 'connection' is renamed as service and should be used instead
        prepare_service_value(attributes)
        super
      end

      # Proxmox create object requires identity given by client
      # def save
      #   identity ? update : create
      # end

      # Updates a record
      def update
        # raise Fog::Proxmox::Errors::InterfaceNotImplemented
      end

      # Creates a record
      def create
        # raise Fog::Proxmox::Errors::InterfaceNotImplemented
      end

      # Destroys a record
      def destroy
        # raise Fog::Proxmox::Errors::InterfaceNotImplemented
      end
    end
  end
end
