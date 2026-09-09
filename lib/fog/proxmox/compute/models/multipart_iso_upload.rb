# frozen_string_literal: true

# This file is part of Fog::Proxmox.

# Fog::Proxmox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Fog::Proxmox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Fog::Proxmox. If not, see <http://www.gnu.org/licenses/>.

require 'securerandom'
require 'excon'
require 'fog/proxmox/compute/models/multipart_body'

module Fog
  module Proxmox
    # Prepares a streamed multipart ISO upload and its content type.
    class MultipartIsoUpload
      attr_reader :body, :content_type

      def initialize(body_params)
        filename = body_params.fetch(:filename)
        raise ArgumentError, "Invalid ISO filename: #{filename}" unless filename.match?(/\A[a-zA-Z0-9][a-zA-Z0-9._-]*\.iso\z/i)

        file = body_params.fetch(:file)

        boundary = '-' * 30 + SecureRandom.hex(15)
        prefix = build_multipart_content(boundary, 'content', 'iso')
        prefix << build_multipart_header(boundary, 'filename', filename: filename)
        @body = MultipartBody.new(prefix, file, build_multipart_closing(boundary))

        @content_type = "multipart/form-data; boundary=#{boundary}"
      end

      private

      def build_multipart_header(boundary, name, filename: nil)
        newline = Excon::CR_NL
        header = ::String.new(encoding: Encoding::BINARY)
        header << "--#{boundary}#{newline}"
        header << %(Content-Disposition: form-data; name="#{name}")
        header << %(; filename="#{filename}") if filename
        header << newline
        header << "Content-Type: application/octet-stream#{newline}" if filename
        header << newline
      end

      def build_multipart_content(boundary, name, value)
        build_multipart_header(boundary, name) << value << Excon::CR_NL
      end

      def build_multipart_closing(boundary)
        "#{Excon::CR_NL}--#{boundary}--#{Excon::CR_NL}".b
      end
    end
  end
end
