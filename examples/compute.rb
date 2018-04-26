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

# There are basically two modes of operation for these specs.
#
# 1. ENV[PVE_URL] exists: talk to an actual Proxmox server and record HTTP
#    traffic in VCRs at "spec/debug" (credentials are read from the conventional
#    environment variables: PVE_URL, PVE_USERNAME, PVE_PASSWORD)
# 2. otherwise (Travis, etc): use VCRs at "spec/fixtures/proxmox/#{service}"

require 'fog/proxmox'

pve_url = 'https://172.26.49.146:8006/api2/json'
pve_username = 'root@pam'
pve_password = 'proxmox01'

# Create service compute
compute = Fog::Compute::Proxmox.new(
  pve_url: pve_url,
  pve_username: pve_username,
  pve_password: pve_password
)

# Create pools
pool_hash = { poolid: 'pool1' }
compute.domains.create(pool_hash)

# Get one pool by id
pool1 = compute.pools.find_by_id 'pool1'

# Update pool
pool1.comment 'pool 1'
pool1.update

# List all pools
compute.pools.all

# List pool by pool
compute.pools.each do |pool|
  # pool ...
end

# Delete pool
pool1.destroy

# Create servers
node = 'pve'
server_hash = { node: node }

# Get next free vmid
vmid = compute.servers.next_id
server_hash.store(:vmid, vmid)

compute.servers.create(server_hash)
# Check already used vmid
valid = compute.servers.id_valid? vmid

# Get server
server = compute.servers.get(node, vmid)

# Update config server
# Add cdrom empty
config_hash = { ide2: 'none,media=cdrom' }
server.update(config_hash)
# Add hdd
config_hash = { virtio0: 'local-lvm:1,backup=no,replicate=0' }
server.update(config_hash)
# Add network interface
config_hash = { net0: 'virtio,bridge=vmbr0' }
server.update(config_hash)
# Add start at boot, keyboard fr, linux 3.x os type, kvm hardware disabled (proxmox guest in virtualbox)
config_hash = { onboot: 1, keyboard: 'fr', ostype: 'l26', kvm: 0 }
server.update(config_hash)
# List all servers
servers_all = compute.servers.all

# Start server
server.action('start')
while server.status == 'stopped'
  server = compute.servers.get(node, vmid)
  sleep 1
end
server.ready?
# Suspend server
server.action('suspend')
while server.qmpstatus == 'running'
  server = compute.servers.get(node, vmid)
  sleep 1
end
# Resume server
server.action('resume')
while server.qmpstatus == 'paused'
  server = compute.servers.get(node, vmid)
  sleep 1
end
# Stop server
server.action('stop')
while server.status == 'running'
  server = compute.servers.get(node, vmid)
  sleep 1
end
# Delete
server.destroy

# List 1 task
options = { limit: 1 }
node = 'pve'
tasks = compute.tasks.search(node, options)
# Get task
upid = tasks[0].upid
task = compute.tasks.find_by_id(node, upid)
# Stop task
task.stop
