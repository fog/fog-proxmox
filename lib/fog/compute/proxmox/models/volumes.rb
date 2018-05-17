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
require 'fog/compute/proxmox/models/volume'

module Fog
  module Compute
    class Proxmox
      # class Volumes Collection of volumes
      class Volumes < Fog::Proxmox::Collection
        model Fog::Compute::Proxmox::Volume
        attribute :node
        attribute :storage

        def new(attributes = {})
          requires :node, :storage
          super({ node: node, storage: storage }.merge(attributes))
        end

        def all
          search
        end

        def search(options = {})
          requires :node, :storage
          load_response(service.list_volumes(node, storage, options), 'volumes')
        end

        def import(params)
          requires :node, :storage          
          options = params.reject { |key,_value| key == :absolute_path }
          file = File.new(params[:absolute_path], 'r')
          options = options.merge(request_block: chunker(file))
          task_wait_for(service.upload_image(node, storage, options))
        ensure
          file.close
        end

        def task_wait_for(task_upid)
          task = node.tasks.get task_upid
          task.wait_for { finished? }        
          task.succeeded?
        end

        def list_by_content_type(content)
          search(content: content)
        end

        def list_by_content_type_and_by_server(content, vmid)
          search(content: content, vmid: vmid)
        end

        def get(id)
          all
          cached_volume = find { |volume| volume.id == id }
          return cached_volume if cached_volume
        end

        def destroy(id)
          volume = get(id)
          volume.destroy
        end

        private

        def chunker(file)
          Excon.defaults[:nonblock] = false
          chunker = lambda do
            file.read(Excon.defaults[:chunk_size]).to_s
          end
          chunker
        end

      end
    end
  end
end
