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

module Fog
  module Proxmox
    # An IO-like multipart body that streams a file between a prefix and suffix.
    class MultipartBody
      attr_reader :size

      def initialize(prefix, file, suffix)
        @prefix = prefix
        @file = file
        @suffix = suffix
        @size = prefix.bytesize + file_size + suffix.bytesize
        rewind
      end

      def read(length = nil, outbuf = nil)
        length = @size - @position if length.nil?
        raise ArgumentError, 'negative length' if length.negative?

        result = ::String.new(encoding: Encoding::BINARY)
        read_into(result, length)
        result = nil if result.empty? && length.positive? && @part > 2

        return result unless outbuf

        outbuf.replace(result || '')
        result && outbuf
      end

      def rewind
        @file.rewind
        @part = 0
        @offset = 0
        @position = 0
        0
      end

      def binmode
        @file.binmode if @file.respond_to?(:binmode)
        self
      end

      private

      def file_size
        return @file.size if @file.respond_to?(:size)
        return @file.stat.size if @file.respond_to?(:stat)

        raise ArgumentError, 'Upload file size cannot be determined'
      end

      def read_into(result, length)
        while result.bytesize < length && @part <= 2
          remaining = length - result.bytesize
          chunk = @part == 1 ? @file.read(remaining) : read_string_part(remaining)

          if chunk.nil? || chunk.empty?
            @part += 1
            @offset = 0
          else
            result << chunk
            @position += chunk.bytesize
          end
        end
      end

      def read_string_part(length)
        string = @part.zero? ? @prefix : @suffix
        chunk = string.byteslice(@offset, length)
        @offset += chunk.bytesize if chunk
        chunk
      end
    end
  end
end
