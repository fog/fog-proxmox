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