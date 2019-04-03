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
      # class Task model of a node
      class Task < Fog::Model
        identity  :upid
        attribute :node_id, aliases: :node
        attribute :status
        attribute :exitstatus
        attribute :pid
        attribute :user
        attribute :id, aliases: :vmid
        attribute :type
        attribute :pstart
        attribute :starttime
        attribute :endtime
        attribute :status_details
        attribute :log

        def initialize(new_attributes = {})
          prepare_service_value(new_attributes)
          attributes[:node_id] = new_attributes[:node_id] unless new_attributes[:node_id].nil?
          attributes[:upid] = new_attributes['upid'] unless new_attributes['upid'].nil?
          requires :node_id, :upid
          super(new_attributes)
        end

        def succeeded?
          finished? && exitstatus == 'OK'
        end

        def finished?
          status == 'stopped'
        end

        def running?
          status == 'running'
        end

        def stop
          service.stop_task(node_id, upid)
        end

        def reload
          object = collection.get(upid)
          merge_attributes(object.attributes)
        end
      end
    end
  end
end
