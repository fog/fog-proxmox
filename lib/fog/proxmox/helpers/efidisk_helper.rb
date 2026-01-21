# frozen_string_literal: true

# Copyright 2026 ATIX AG

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
    # module EfidiskHelper mixins
    module EfidiskHelper
      def self.flatten(efidisk)
        return '' if efidisk.nil?

        volume = efidisk[:volid]
        options = []

        if efidisk.key?(:efitype)
          options.push("efitype=#{efidisk[:efitype]}")
        else
          options.push('efitype=4m') # default efitype
        end

        options.push("size=#{efidisk[:size]}") if efidisk.key?(:size)

        if efidisk.key?(:pre_enrolled_keys)
          options.push("pre-enrolled-keys=#{efidisk[:pre_enrolled_keys]}")
        else
          options.push('pre-enrolled-keys=0') # Use 0=disabled if not given
        end

        { "efidisk#{efidisk[:id]}": "#{volume},#{options.join(',')}" }
      end

      def self.extract_key(name, efidisk)
        matches = efidisk.match(%r{,{0,1}#{name}={1}(?<name_value>[\w/.:]+)})
        matches ? matches[:name_value] : matches
      end

      def self.extract_storage(key)
        values_a = key.scan(%r{^(([\w-]+):{0,1}([\w/.-]+))})
        values = values_a.first if values_a
        values[1]
      end

      def self.extract(efidisk_key)
        efidisk = efidisk_key.dup
        # convert "-" to "_" in 'local:110/vm-110-disk-0.qcow2,efitype=4m,pre-enrolled-keys=1,size=528K'
        efidisk&.gsub!('pre-enrolled-keys', 'pre_enrolled_keys')

        names = %i[efitype pre_enrolled_keys size]
        efidisk_hash = {
          id: 0,
          volid: efidisk.split(',')[0],
          storage: extract_storage(efidisk)
        }
        names.each do |name|
          efidisk_hash.store(name.to_sym, extract_key(name, efidisk))
        end
        efidisk_hash
      end
    end
  end
end
