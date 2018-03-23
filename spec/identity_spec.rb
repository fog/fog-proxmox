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

describe Fog::Identity::Proxmox::V3 do
  before :all do
    @proxmox_vcr = ProxmoxVCR.new(
      :vcr_directory => 'spec/fixtures/proxmox/identity',
      :service_class => Fog::Identity::Proxmox
    )
    @service = @proxmox_vcr.service
    @pve_url = @proxmox_vcr.pve_url
  end

  it 'authenticates with username and password' do
    VCR.use_cassette('auth') do
      Fog::Identity::Proxmox.new(
        :username => @proxmox_vcr.username,
        :password   => @proxmox_vcr.password,
        :pve_url  => "#{@pve_url}/access/ticket"
      )
    end
end
end