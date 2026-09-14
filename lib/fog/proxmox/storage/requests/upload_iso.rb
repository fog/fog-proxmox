# frozen_string_literal: true

# This file is part of Fog::Proxmox.

# Fog::Proxmox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Fog::Proxmox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Fog::Proxmox. If not, see <http://www.gnu.org/licenses/>.

require 'fog/proxmox/compute/models/multipart_iso_upload'

module Fog
  module Proxmox
    class Storage
      # class Real upload_iso request
      class Real
        def upload_iso(path_params, body_params)
          node = path_params[:node]
          storage = path_params[:storage]
          upload = MultipartIsoUpload.new(body_params)

          request(
            expects: [200],
            method: 'POST',
            path: "nodes/#{node}/storage/#{storage}/upload",
            body: upload.body,
            headers: { 'Content-Type' => upload.content_type }
          )
        end
      end

      # class Mock upload_iso request
      class Mock
        def upload_iso(_path_params, _body_params); end
      end
    end
  end
end
