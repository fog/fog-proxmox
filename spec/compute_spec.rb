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

describe Fog::Compute::Proxmox do
  before :all do
    @proxmox_vcr = ProxmoxVCR.new(
      vcr_directory: 'spec/fixtures/proxmox/compute',
      service_class: Fog::Compute::Proxmox
    )
    @service = @proxmox_vcr.service
    @pve_url = @proxmox_vcr.url
    @username = @proxmox_vcr.username
    @password = @proxmox_vcr.password
    @ticket = @proxmox_vcr.ticket
    @csrftoken = @proxmox_vcr.csrftoken
    @deadline = @proxmox_vcr.deadline
  end

  it 'CRUD pools' do
    VCR.use_cassette('pools') do
      pool_hash = { poolid: 'pool1' }
      # Create 1st time
      @service.pools.create(pool_hash)
      # Find by id
      pool = @service.pools.find_by_id pool_hash[:poolid]
      pool.wont_be_nil
      # Create 2nd time must fails
      proc do
        @service.pools.create(pool_hash)
      end.must_raise Excon::Errors::InternalServerError
      # Update
      pool.comment = 'Pool 1'
      pool.update
      # all pools
      pools_all = @service.pools.all
      pools_all.wont_be_nil
      pools_all.wont_be_empty
      pools_all.must_include pool
      # Delete
      pool.destroy
      proc do
        @service.pools.find_by_id pool_hash[:poolid]
      end.must_raise Excon::Errors::InternalServerError
    end
  end

end
