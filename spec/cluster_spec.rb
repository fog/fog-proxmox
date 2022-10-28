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
require_relative './proxmox_vcr'

describe Fog::Proxmox::Cluster do
  before :all do
    @proxmox_vcr = ProxmoxVCR.new(
      vcr_directory: 'spec/fixtures/proxmox/cluster',
      service_class: Fog::Proxmox::Cluster
    )
    @service = @proxmox_vcr.service
    @proxmox_url = @proxmox_vcr.url
    @username = @proxmox_vcr.username
    @password = @proxmox_vcr.password
    @tokenid = @proxmox_vcr.tokenid
    @token = @proxmox_vcr.token
  end

  it 'Manage Clusters' do
    VCR.use_cassette('cluster') do
      # List all resources
      resources = @service.resources.all
      _(resources).wont_be_nil
      _(resources).wont_be_empty
      _(resources.size).must_equal 3 # TODO: add mock resources
      # List all resources of type qemu
      qemu_resources = @service.resources.get('qemu')
      _(qemu_resources).wont_be_nil
      _(qemu_resources).wont_be_empty
      _(qemu_resources.size).must_equal 1 # TODO: add mock resources
    end
  end
end
