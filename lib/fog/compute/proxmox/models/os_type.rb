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

module Fog
  module Compute
    class Proxmox
      # Osttype class
      class OsType
        include Enumerable
        def each
          yield 'wxp'
          yield 'w2k'
          yield 'w2k3'
          yield 'w2k8'
          yield 'wvista'
          yield 'win7'
          yield 'win8'
          yield 'win10'
          yield 'l24'
          yield 'l26'
          yield 'solaris'
          yield 'other'
        end
      end
    end
  end
end
