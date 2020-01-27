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

require 'fog/proxmox/hash'

module Fog
  module Proxmox
    # module IpHelper mixins
    module IpHelper

      CIDR_REGEXP = /^(([0-9]{1,3}\.){3}[0-9]{1,3})(\/([0-9]|[1-2][0-9]|3[0-2]))?$/
      IP_REGEXP = /^(([0-9]{1,3}\.){3}[0-9]{1,3})$/
      CIDR_SUFFIX_REGEXP = /^([0-9]|[1-2][0-9]|3[0-2])$/
    
      def self.cidr?(ip)
        CIDR_REGEXP.match?(ip)
      end

      def self.suffix(ip)
        if cidr = CIDR_REGEXP.match(ip)
          cidr[4]
        end
      end

      def self.ip?(ip)
        IP_REGEXP.match?(ip)
      end

      def self.cidr_suffix?(suffix)
        CIDR_SUFFIX_REGEXP.match?(suffix)
      end

      def self.ip(ip)
        if cidr = CIDR_REGEXP.match(ip)
          cidr[1]
        end
      end

      def self.to_cidr(ip,suffix = nil)
        return nil unless self.ip?(ip) && (!suffix || self.cidr_suffix?(suffix))
        cidr = "#{ip}"
        cidr += "/#{suffix}" if self.cidr_suffix?(suffix)
        cidr
      end
    end
  end
end
