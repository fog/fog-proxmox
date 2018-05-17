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

# frozen_string_literal: true

require 'fog/proxmox/json'

module Fog
  module Compute
    class Proxmox
      # class Real upload_image request
      class Real
        def upload_image(node, storage, options)
          params = options.reject { |key,_value| key == :request_block }
          request_hash = {
            headers: { 'Content-Type' => 'application/x-cd-image' },
            expects: [200],
            method: 'POST',
            path: "nodes/#{node}/storage/#{storage}/upload",
            body: URI.encode_www_form(params)
          } 
          request_hash[:request_block] = options[:request_block] if options[:request_block]
          response = request(request_hash)
          Fog::Proxmox::Json.get_data(response)
        end
      end

      # class Mock upload_image request
      class Mock
        def upload_image(node, storage, body, options)
          response = Excon::Response.new
          response.status = 204
          Fog::Proxmox::Json.get_data(response)
        end
      end
    end
  end
end
