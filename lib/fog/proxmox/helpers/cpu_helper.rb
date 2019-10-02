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

module Fog
  module Proxmox
    # module Cpu mixins
    module CpuHelper
      def self.extract(cpu)
        cpu_regexp = /^(cputype=)?(\w+)(,flags=){0,1}(\+[\w-]+){0,1}[;]{0,1}(\+[\w-]+){0,1}/
        cpu&.is_a?(String) && cpu&.match(cpu_regexp) ? cpu&.scan(cpu_regexp)&.first : []
      end

      def self.extract_type(cpu)
        cpu_a = extract(cpu)
        cpu_a[1] unless cpu_a.empty? || cpu_a.size < 2
      end

      def self.extract_pcid(cpu)
        has?('+pcid', cpu)
      end

      def self.extract_spectre(cpu)
        has?('+spec-ctrl', cpu)
      end

      def self.has?(value, cpu)
        cpu_a = extract(cpu)
        cpu_a.include? value
      end
    end
  end
end
