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

require 'fog/proxmox/models/collection'
require 'fog/compute/proxmox/models/task'

module Fog
  module Compute
    class Proxmox
      # class Tasks Collection of node
      class Tasks < Fog::Proxmox::Collection
        model Fog::Compute::Proxmox::Task

        def search(node, options = {})
          load_response(service.list_tasks(node, options), 'tasks')
        end

        def find_by_id(node, id)
          status_details = service.status_task(node, id)
          log_array = service.log_task(node, id, {})
          log = ''
          log_array.each do |line_hash|
            log += line_hash['t'].to_s + "\n"
          end
          task_hash = status_details.merge(log: log)
          Fog::Compute::Proxmox::Task.new(
            task_hash.merge(service: service)
          )
        end
      end
    end
  end
end
