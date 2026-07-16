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
require 'fog/proxmox/errors'

describe Fog::Proxmox::Errors do
  # Builds the Excon error a Proxmox 500 raises, with the reason-phrase an
  # intermediary would have left in place of the upstream one.
  def error_for(body, reason_phrase)
    response = Excon::Response.new(status: 500, reason_phrase: reason_phrase, body: body)
    Excon::Errors::InternalServerError.new('Expected([200]) <=> Actual(500)', nil, response)
  end

  let(:proxmox_message) do
    "Configuration file 'nodes/example-prox01/qemu-server/153157505.conf' does not exist"
  end

  let(:proxmox_body) do
    Fog::JSON.encode('message' => "#{proxmox_message}\n", 'data' => nil)
  end

  describe '#message' do
    it 'returns the message of the body when the reason phrase was rewritten' do
      error = error_for(proxmox_body, 'Internal Server Error')
      assert_equal proxmox_message, Fog::Proxmox::Errors.message(error)
    end

    it 'returns the message of the body when the reason phrase was kept' do
      error = error_for(proxmox_body, proxmox_message)
      assert_equal proxmox_message, Fog::Proxmox::Errors.message(error)
    end

    it 'falls back on the reason phrase when the body is not JSON' do
      error = error_for('<html>502 Bad Gateway</html>', 'Bad Gateway')
      assert_equal 'Bad Gateway', Fog::Proxmox::Errors.message(error)
    end

    it 'falls back on the reason phrase when the body is empty' do
      error = error_for('', 'Internal Server Error')
      assert_equal 'Internal Server Error', Fog::Proxmox::Errors.message(error)
    end

    it 'falls back on the reason phrase when the body carries no message' do
      error = error_for(Fog::JSON.encode('data' => nil), 'Internal Server Error')
      assert_equal 'Internal Server Error', Fog::Proxmox::Errors.message(error)
    end

    it 'returns nil when the error has no response' do
      assert_nil Fog::Proxmox::Errors.message(StandardError.new('boom'))
    end
  end
end
