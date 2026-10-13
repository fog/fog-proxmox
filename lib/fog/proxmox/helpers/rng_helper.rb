# frozen_string_literal: true

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

require 'fog/proxmox/hash'

module Fog
  module Proxmox
    # Convert RNG devices to and from Proxmox configuration strings
    module RngHelper
      RNG_SOURCES = %w[/dev/urandom /dev/random /dev/hwrng].freeze

      def self.flatten(rng)
        return {} if rng.nil?

        options = rng.select do |key, value|
          %i[max_bytes period source].include?(key) && !value.nil? && value != ''
        end

        validate(options)

        { rng0: Fog::Proxmox::Hash.stringify(options) }
      end

      def self.validate(rng)
        raise ArgumentError, 'RNG source is required and must be /dev/urandom, /dev/random, or /dev/hwrng' unless RNG_SOURCES.include?(rng[:source].to_s)

        %i[max_bytes period].each do |key|
          next if rng[key].nil? || rng[key] == ''
          next if rng[key].to_s.match?(/\A[0-9]+\z/)

          raise ArgumentError, "RNG #{key} must be a non-negative integer"
        end

        true
      end

      def self.extract(rng)
        options = rng.split(',').each_with_object({}) do |option, values|
          key, value = option.split('=', 2)
          values[key.to_sym] = value&.sub(/\A"(.*)"\z/, '\1')
        end

        options.slice(:max_bytes, :period, :source)
      end
    end
  end
end
