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

  it 'Manage tasks' do
    VCR.use_cassette('tasks') do
      # List all tasks
      options = { limit: 1 }
      node = 'pve'
      tasks = @service.tasks.search(node, options)
      tasks.wont_be_nil
      tasks.wont_be_empty
      # Get task
      upid = tasks[0].upid
      task = @service.tasks.find_by_id(node, upid)
      task.wont_be_nil
      # Stop task
      task.stop
      task.exitstatus.must_equal 'OK'
    end
  end

  it 'CRUD servers' do
    VCR.use_cassette('servers') do
      node = 'pve'
      server_hash = { node: node }
      # Get next vmid
      vmid = @service.servers.next_id
      server_hash.store(:vmid, vmid)
      # Check valid vmid
      valid = @service.servers.id_valid? vmid
      valid.must_equal true
      # Check not valid vmid
      valid = @service.servers.id_valid? 99
      valid.must_equal false
      # Create 1st time
      @service.servers.create(server_hash)
      # Check already used vmid
      valid = @service.servers.id_valid? vmid
      # Clone server
      newid = @service.servers.next_id
      # Get server
      server = @service.servers.get(node, vmid)
      # Snapshot it
      # server.backup
      # Delete snapshot
      # /api2/json does not offer this feature, 
      # but /api2/extjs does
      # Clone it
      server.clone(newid)
      # Get clone
      clone = @service.servers.get(node, newid)
      # Delete clone
      clone.destroy
      proc do
        @service.servers.get(node, newid)
      end.must_raise Excon::Errors::InternalServerError
      # Create 2nd time must fails
      proc do
        @service.servers.create(server_hash)
      end.must_raise Excon::Errors::InternalServerError
      # Update config server
      # Add cdrom empty
      config_hash = { ide2: 'none,media=cdrom' }
      server.update(config_hash)
      # Add hdd
      # Find available storages to images
      storages = @service.storages.list_store_images(node)
      storage = storages[0]
      volume = { id: 'virtio0', storage: storage.storage, size: '1' }
      options = { backup: 0, replicate: 0 }
      server.attach_volume(volume, options)
      # Add network interface
      config_hash = { net0: 'virtio,bridge=vmbr0' }
      server.update(config_hash)
      # Add start at boot, keyboard fr, 
      # linux 4.x os type, kvm hardware disabled (proxmox guest in virtualbox)
      config_hash = { onboot: 1, keyboard: 'fr', ostype: 'l26', kvm: 0 }
      server.update(config_hash)
      # all servers
      servers_all = @service.servers.all
      servers_all.wont_be_nil
      servers_all.wont_be_empty
      servers_all.must_include server
      # Start server
      server.action('start')
      server.wait_for { server.status == 'running' }
      status = server.ready?
      status.must_equal true
      # Suspend server
      server.action('suspend')
      server.wait_for {server.qmpstatus == 'paused'}
      qmpstatus = server.qmpstatus
      qmpstatus.must_equal 'paused'
      # Resume server
      server.action('resume')
      server.wait_for { server.ready? }
      status = server.ready?
      status.must_equal true
      # Stop server
      server.action('stop')
      server.wait_for { server.status == 'stopped' }
      status = server.status
      status.must_equal 'stopped'
      proc do
        server.action('hello')
      end.must_raise Fog::Errors::Error
      # Delete
      server.destroy
      sleep 1
      proc do
        @service.servers.get(node, vmid)
      end.must_raise Excon::Errors::InternalServerError
    end
  end
end
