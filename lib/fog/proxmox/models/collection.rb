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

require 'fog/core/collection'
require 'fog/proxmox/errors'

module Fog
  module Proxmox
    # class Collection proxmox
    class Collection < Fog::Collection
      attr_accessor :response

      def load_response(response, _index = nil, attributes_ignored = [])
        body = JSON.decode(response.body)
        objects = body['data']
        clear && objects.each { |object| self << new(clear_ignored_attributes(object, attributes_ignored)) }
        self.response = response
        self
      end

      # clear attributes non persistent
      def clear_ignored_attributes(object, attributes_ignored = [])
        attributes_ignored.each { |attribute| object.delete_if { |key, _value| key == attribute } }
        object
      end

      def read(response, attribute)
        response.body[attribute]
      end

      # Proxmox object creation requires identity and return null
      def create(attributes = {})
        object = new(attributes)
        object.create(attributes)
      end

      # Returns detailed list of records
      def all(_options = {})
        raise Fog::Proxmox::Errors::InterfaceNotImplemented, not_implemented('all')
      end

      # Returns non detailed list of records, usually just subset of attributes,
      # which makes this call more effective.
      # Not all Proxmox services support non detailed list, so it delegates to :all by default.
      def summary(options = {})
        all(options)
      end

      # Gets record given record's UUID
      def get(_uuid)
        raise Fog::Proxmox::Errors::InterfaceNotImplemented, not_implemented('get')
      end

      def find_by_id(uuid)
        get(uuid)
      end

      # Destroys record given record's UUID
      def destroy(_uuid)
        raise Fog::Proxmox::Errors::InterfaceNotImplemented, not_implemented('destroy')
      end

      def not_implemented(method)
        "Method #{method} is not implemented"
      end
    end
  end
end
