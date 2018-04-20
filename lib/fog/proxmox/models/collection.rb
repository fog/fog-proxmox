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

module Fog
  module Proxmox
    class Collection < Fog::Collection
      # It's important to store the whole response, it contains e.g. important info about whether there is another
      # page of data.
      attr_accessor :response

      def load_response(response, index = nil, attributes_ignored = [])
        # Delete it index if it's there, so we don't store response with data twice, but we store only metadata
        body = JSON.decode(response.body)
        objects = body['data']
        clear && objects.each { |object| self << new(clear_ignored_attributes(object,attributes_ignored)) }
        self.response = response
        self
      end

      # clear attributes non persistent
      def clear_ignored_attributes(object, attributes_ignored = [])
        attributes_ignored.each { |attribute| object.delete_if {|k,v| k == attribute}}
        object
      end

      def get(response, attribute)
        return response.body[attribute]
      end

      # Proxmox object creation is specific because it requires identity and return null
      def create(attributes = {})
        object = new(attributes)
        object.create
      end

      # Returns detailed list of records
      def all(options = {})
        raise Fog::Proxmox::Errors::InterfaceNotImplemented.new('Method :all is not implemented')
      end

      # Returns non detailed list of records, usually just subset of attributes, which makes this call more effective.
      # Not all Proxmox services support non detailed list, so it delegates to :all by default.
      def summary(options = {})
        all(options)
      end

      # Gets record given record's UUID
      def get(uuid)
        raise Fog::Proxmox::Errors::InterfaceNotImplemented.new('Method :get is not implemented')
      end

      def find_by_id(uuid)
        get(uuid)
      end

      # Destroys record given record's UUID
      def destroy(uuid)
        raise Fog::Proxmox::Errors::InterfaceNotImplemented.new('Method :destroy is not implemented')
      end
    end
  end
end
