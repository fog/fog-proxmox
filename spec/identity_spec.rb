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

describe Fog::Identity::Proxmox do

  before :all do
    @proxmox_vcr = ProxmoxVCR.new(
      {:vcr_directory => 'spec/fixtures/proxmox/identity',
      :service_class => Fog::Identity::Proxmox}
    )
    @service = @proxmox_vcr.service
    @proxmox_url = @proxmox_vcr.proxmox_url
    @ticket = @proxmox_vcr.ticket
    @csrftoken = @proxmox_vcr.csrftoken
  end

  it 'authenticates with username and password' do
    VCR.use_cassette('auth') do
      Fog::Identity::Proxmox.new({
        :proxmox_username => 'root@pam',
        :proxmox_password => 'proxmox01',
        :proxmox_url  => "#{@proxmox_url}/access/ticket"}
      )
    end
  end

  it 'authenticates with ticket' do
    VCR.use_cassette('ticket') do
      Fog::Identity::Proxmox.new({
        :proxmox_ticket => @ticket,
        :proxmox_csrftoken => @csrftoken,
        :proxmox_url  => "#{@proxmox_url}/access/ticket"}
      )
    end
  end

end
