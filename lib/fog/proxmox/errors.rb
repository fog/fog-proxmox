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

require 'fog/json'

module Fog
  module Proxmox
    module Errors
      # Returns the Proxmox error message carried by an Excon error response.
      #
      # The message is read from the JSON body ({"message": "...", "data": null})
      # in preference to the HTTP reason-phrase, because a reason-phrase is not a
      # reliable channel for information: it may be rewritten by an intermediary
      # (a reverse proxy replacing Proxmox's "500 Configuration file '...' does not
      # exist" with a generic "500 Internal Server Error"), translated for a locale,
      # or discarded when the message is forwarded over another version of HTTP.
      # RFC 9112 section 4 therefore says a client SHOULD ignore it. See
      # https://datatracker.ietf.org/doc/html/rfc9112#section-4-8 and
      # https://github.com/fog/fog-proxmox/issues/108
      #
      # The reason-phrase is kept as a fallback for responses without a JSON body.
      def self.message(error)
        return nil unless error.respond_to?(:response) && error.response.respond_to?(:data)

        data = error.response.data
        # ::Hash, as Hash resolves to Fog::Proxmox::Hash in this namespace.
        return nil unless data.is_a?(::Hash)

        message_from_body(data[:body]) || data[:reason_phrase]
      end

      def self.message_from_body(body)
        decoded = Fog::JSON.decode(body)
        return nil unless decoded.is_a?(::Hash)

        message = decoded['message']
        # Proxmox terminates its messages with a newline.
        message.strip if message.is_a?(String)
      rescue Fog::JSON::DecodeError
        nil
      end
      private_class_method :message_from_body

      # class ServiceError
      class ServiceError < Fog::Errors::Error
        attr_reader :response_data

        def self.slurp(error)
          if error.response.body.empty?
            data = nil
            message = nil
          else
            data = Fog::JSON.decode(error.response.body)
            message = data['message']
            data1 = data.values.first
            message = data1['message'] if message.nil? && !data1.nil?
          end

          new_error = super(error, message)
          new_error.instance_variable_set(:@response_data, data)
          new_error
        end
      end

      # class ServiceUnavailable error
      class ServiceUnavailable < ServiceError; end

      # class BadRequest error
      class BadRequest < ServiceError
        attr_reader :validation_errors

        def self.slurp(error)
          new_error = super(error)
          unless new_error.response_data.nil? || new_error.response_data['badRequest'].nil?
            new_error.instance_variable_set(:@validation_errors,
                                            new_error.response_data['badRequest']['validationErrors'])
          end
          new_error
        end
      end

      # class InterfaceNotImplemented error
      class InterfaceNotImplemented < Fog::Errors::Error; end
    end
  end
end
