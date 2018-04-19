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
      :service_class  => Fog::Identity::Proxmox}
    )
    @service = @proxmox_vcr.service
    @proxmox_url = @proxmox_vcr.proxmox_url
    @ticket = @proxmox_vcr.ticket
    @csrftoken = @proxmox_vcr.csrftoken
    @ticket_deadline = @proxmox_vcr.ticket_deadline
  end

  it 'authenticates with username and password' do
    VCR.use_cassette('auth') do
      Fog::Identity::Proxmox.new({
        :proxmox_username => 'root@pam',
        :proxmox_password => 'proxmox01',
        :proxmox_url      => "#{@proxmox_url}",
        :proxmox_path     => "/access/ticket"}
      )
    end
  end
    
  it 'gets server version' do
    VCR.use_cassette('get_version') do      
      @service.get_version
    end
  end
    
  it 'lists users' do
    VCR.use_cassette('list_users') do
      # all users
      users_all = @service.users.all
      users_all.wont_be_nil
      users_all.wont_be_empty
      # disabled users
      users_disabled = @service.users.all({'enabled' => 0})
      users_disabled.wont_be_nil
      users_disabled.must_be_empty
    end
  end
    
  it 'CRUD user' do
    VCR.use_cassette('crud_user') do
      bob_hash = {:userid => 'bobsinclar@pve', :firstname => 'Bob', :lastname => 'Sinclar', :email => "bobsinclar@proxmox.com"}
      # Create 1st time
      @service.users.create(bob_hash) 
      # Find by id
      bob = @service.users.find_by_id bob_hash[:userid]
      bob.wont_be_nil
      # Create 2nd time must fails
      proc do
        @service.users.create(bob_hash)
      end.must_raise Excon::Errors::InternalServerError
      #bob.email.must_be_equal bob_hash[:email]
      # Update
      bob.comment = 'novelist'
      bob.enable  = 0
      bob.update
      # Delete
      bob.destroy
      proc { @service.users.find_by_id bob_hash[:userid] }.must_raise Excon::Errors::InternalServerError
    end
  end

end
