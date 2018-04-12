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
    class Model < Fog::Model

      # Initialize a record
      def initialize(attributes)
        # Old 'connection' is renamed as service and should be used instead
        prepare_service_value(attributes)
        super
      end

      # Saves a record, call create or update based on identity, which marks if object was already created
      def save
        identity ? update : create
      end

      # Updates a record
      def update
        # raise Fog::Proxmox::Errors::InterfaceNotImplemented.new('Method :get is not implemented')
      end

      # Creates a record
      def create
        # raise Fog::Proxmox::Errors::InterfaceNotImplemented.new('Method :get is not implemented')
      end

      # Destroys a record
      def destroy
        # raise Fog::Proxmox::Errors::InterfaceNotImplemented.new('Method :get is not implemented')
      end
    end
  end
end
