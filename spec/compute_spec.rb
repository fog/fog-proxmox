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

  it 'Manage tasks' do
    VCR.use_cassette('tasks') do
      # List all tasks
      options = { limit: 1 }
      node_name = 'pve'
      node = @service.nodes.find_by_id node_name
      tasks = node.tasks.search(options)
      tasks.wont_be_nil
      tasks.wont_be_empty
      # Get task
      upid = tasks[0].upid
      task = node.tasks.find_by_id(upid)
      task.wont_be_nil
      # Stop task
      task.stop
      task.exitstatus.must_equal 'OK'
    end
  end

  it 'CRUD servers' do
    VCR.use_cassette('servers') do
      node_name = 'pve'
      node = @service.nodes.find_by_id node_name
      # Get next vmid
      vmid = node.servers.next_id
      server_hash = { vmid: vmid }
      # Check valid vmid
      valid = @service.servers.id_valid? vmid
      valid.must_equal true
      # Check not valid vmid
      valid = @service.servers.id_valid? 99
      valid.must_equal false
      # Create 1st time
      node.servers.create(server_hash)
      # Check already used vmid
      valid = node.servers.id_valid? vmid
      valid.must_equal false
      # Clone server
      newid = node.servers.next_id
      # Get server
      server = node.servers.get vmid
      server.wont_be_nil
      # Backup it
      server.backup(compress: 'lzo')
      # Get this backup image
      # Find available backup storages
      volume = server.backups.first
      volume.wont_be_nil
      # Restore it
      server.restore volume
      # Delete it
      volume.destroy
      # Add hdd
      # Find available storages to images
      storages = node.storages.list_by_content_type 'images'
      storage = storages[0]
      virtio0 = { id: 'virtio0', storage: storage.storage, size: '1' }
      ide0 = { id: 'ide0', storage: storage.storage, size: '1' }
      options = { backup: 0, replicate: 0 }
      server.attach(virtio0, options)
      server.attach(ide0, options)
      server.detach('ide0')
      server.detach('unused0')
      sleep 1
      # Clone it (linked fails)
      server.clone(newid, full: 1)
      # Get clone
      clone = node.servers.get newid
      # Template this clone (read-only)
      clone.template
      # Get clone disk images
      disk_image = clone.disk_images.first
      disk_image.wont_be_nil
      # Delete clone
      clone.destroy
      proc do
        node.servers.get newid
      end.must_raise Excon::Errors::InternalServerError
      # Create 2nd time must fails
      proc do
        node.servers.create server_hash
      end.must_raise Excon::Errors::InternalServerError
      # Update config server
      # Add cdrom empty
      config_hash = { ide2: 'none,media=cdrom' }
      server.update(config_hash)
      # Resize disk server
      server.extend('virtio0', '+1G')
      # Move disk server
      server.move('virtio0', 'local')
      # Add network interface
      config_hash = { net0: 'virtio,bridge=vmbr0' }
      server.update(config_hash)
      # Add start at boot, keyboard fr,
      # linux 4.x os type, kvm hardware disabled (proxmox guest in virtualbox)
      config_hash = { onboot: 1, keyboard: 'fr', ostype: 'l26', kvm: 0 }
      server.update(config_hash)
      # server configs
      config = server.configs.get 'virtio0'
      config.wont_be_nil
      configs = server.configs.all
      configs.wont_be_nil
      configs.wont_be_empty
      configs.must_include config
      # Get a mac adress
      # net0 = server.configs.get 'net0'
      # all servers
      servers_all = node.servers.all
      servers_all.wont_be_nil
      servers_all.wont_be_empty
      servers_all.must_include server
      # Start server
      server.action('start')
      server.wait_for { ready? }
      status = server.ready?
      status.must_equal true
      # Suspend server
      server.action('suspend')
      server.wait_for { server.qmpstatus == 'paused' }
      qmpstatus = server.qmpstatus
      qmpstatus.must_equal 'paused'
      # Resume server
      server.action('resume')
      server.wait_for { ready? }
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
      proc do
        node.servers.get vmid
      end.must_raise Excon::Errors::InternalServerError
    end
  end

  it 'CRUD snapshots' do
    VCR.use_cassette('snapshots') do
      node_name = 'pve'
      node = @service.nodes.find_by_id node_name
      vmid = node.servers.next_id
      server_hash = { vmid: vmid }
      node.servers.create server_hash
      # Create
      snapname = 'snapshot1'
      server = node.servers.get vmid
      snapshot_hash = { name: snapname }
      server.snapshots.create(snapshot_hash)
      # Find by id
      snapshot = server.snapshots.get snapname
      snapshot.wont_be_nil
      # Update
      snapshot.description = 'Snapshot 1'
      snapshot.update
      # all snapshots
      snapshots_all = server.snapshots.all
      snapshots_all.wont_be_nil
      snapshots_all.wont_be_empty
      snapshots_all.must_include snapshot
      # Delete
      taskid = snapshot.destroy
      task = node.tasks.find_by_id taskid
      task.wait_for { finished? }
      server.destroy
    end
  end
end
