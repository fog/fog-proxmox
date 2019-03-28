# frozen_string_literal: true
# Copyright 2018 Tristan Robert

# This file is part of Fog::Proxmox.

# Fog::Proxmox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
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
      # class Node model of VMs
      class Node < Fog::Model
        identity  :node
        attribute :status
        attribute :wait
        attribute :uptime
        attribute :pveversion
        attribute :ksm
        attribute :kversion
        attribute :loadavg
        attribute :rootfs
        attribute :cpu
        attribute :cpuinfo
        attribute :memory
        attribute :idle
        attribute :swap
        attribute :servers
        attribute :tasks
        attribute :storages

        def to_s
          node
        end

        def tasks
          attributes[:tasks] ||= node.nil? ? [] : begin
            Fog::Compute::Proxmox::Tasks.new(service: service,
                                             node_id: node)
            end
        end

        def servers
          attributes[:servers] ||= node.nil? ? [] : begin
            Fog::Compute::Proxmox::Servers.new(service: service,
              node_id: node)
          end
        end

        def containers
          attributes[:containers] ||= node.nil? ? [] : begin
            Fog::Compute::Proxmox::Containers.new(service: service,
              node_id: node)
          end
        end

        def storages
          attributes[:storages] ||= node.nil? ? [] : begin
            Fog::Compute::Proxmox::Storages.new(service: service,
              node_id: node)
          end
        end

        def backup(options = {})
          task_upid = service.backup({ node: node }, options)
          task_upid
        end

        def statistics(output = 'rrddata', options = { timeframe: 'hour', cf: 'AVERAGE'})
          path_params = { node: node, output: output }
          query_params = options
          service.get_node_statistics(path_params,query_params)
        end

      end
    end
  end
end
