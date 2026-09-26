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

require 'spec_helper'
require 'fog/proxmox/compute/models/servers'

describe Fog::Proxmox::Compute::Servers do
  # Raises the Excon error a Proxmox 500 produces, with the reason-phrase an
  # intermediary such as a reverse proxy would have left in place of the
  # upstream one.
  def service_raising(body, reason_phrase)
    response = Excon::Response.new(status: 500, reason_phrase: reason_phrase, body: body)
    error = Excon::Errors::InternalServerError.new('Expected([200]) <=> Actual(500)', nil, response)
    service = Minitest::Mock.new
    service.expect(:get_server_status, nil) { raise error }
    service
  end

  let(:not_found_body) do
    Fog::JSON.encode(
      'message' => "Configuration file 'nodes/example-prox01/qemu-server/153157505.conf' does not exist\n",
      'data' => nil
    )
  end

  def servers(service)
    Fog::Proxmox::Compute::Servers.new(service: service, node_id: 'pve', type: 'qemu')
  end

  describe '#get' do
    it 'raises NotFound when the body says the config does not exist' do
      service = service_raising(not_found_body, 'Internal Server Error')
      assert_raises(Fog::Errors::NotFound) { servers(service).get('153157505') }
    end

    it 'raises the original error when the body reports another failure' do
      service = service_raising(Fog::JSON.encode('message' => "no such user ('root@pam')\n"), 'Internal Server Error')
      assert_raises(Excon::Errors::InternalServerError) { servers(service).get('153157505') }
    end
  end
end
