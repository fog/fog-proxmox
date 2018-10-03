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
        cpu&.scan(/^(cputype=)?(\w+)(,flags=){0,1}(\+[\w-]+){0,1}[;]{0,1}(\+[\w-]+){0,1}/)&.first
      end

      def self.extract_type(cpu)
        extract(cpu)[1] if cpu
      end

      def self.extract_pcid(cpu)
        has?('+pcid', cpu)
      end

      def self.extract_spectre(cpu)
        has?('+spec-ctrl', cpu)
      end

      def self.has?(value, cpu)
        extract(cpu).include? value if cpu
      end
    end
  end
end
