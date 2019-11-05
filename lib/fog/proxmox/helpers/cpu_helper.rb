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
      CPU_REGEXP = /(\bcputype=)?(\w+)[,]?(\bflags=)?(\+[\w-]+)?[;]?(\+[\w-]+)?/
      def self.extract(cpu,i)
        cpu ? CPU_REGEXP.match(cpu.to_s)[i] : ''
      end

      def self.extract_type(cpu)
        extract(cpu,2)
      end

      def self.has_pcid?(cpu)
        extract(cpu,5) == '+pcid'
      end

      def self.has_spectre?(cpu)
        extract(cpu,4) == '+spec-ctrl'
      end
    end
  end
end
