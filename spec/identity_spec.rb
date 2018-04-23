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
    
  it 'CRUD users' do
    VCR.use_cassette('crud_users') do
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
      # all users
      users_all = @service.users.all
      users_all.wont_be_nil
      users_all.wont_be_empty
      users_all.must_include bob
      # Update
      bob.comment = 'novelist'
      bob.enable  = 0
      @service.groups.create({:groupid => 'group1'}) 
      @service.groups.create({:groupid => 'group2'}) 
      bob.groups = ['group1','group2']
      bob.update
      # disabled users
      users_disabled = @service.users.all({'enabled' => 0})
      users_disabled.wont_be_nil
      users_disabled.wont_be_empty
      users_disabled.must_include bob
      # Delete
      bob.destroy
      group1 = @service.groups.find_by_id 'group1'
      group1.destroy
      group2 = @service.groups.find_by_id 'group2'
      group2.destroy
      proc { @service.users.find_by_id bob_hash[:userid] }.must_raise Excon::Errors::InternalServerError
    end
  end

  it 'CRUD groups' do
    VCR.use_cassette('crud_groups') do
      group_hash = {:groupid => 'group1'}
      # Create 1st time
      @service.groups.create(group_hash) 
      # Find by id
      group = @service.groups.find_by_id group_hash[:groupid]
      group.wont_be_nil
      # Create 2nd time must fails
      proc do
        @service.groups.create(group_hash)
      end.must_raise Excon::Errors::InternalServerError
      # Update
      group.comment = 'Group 1'
      group.update
      # all groups
      groups_all = @service.groups.all
      groups_all.wont_be_nil
      groups_all.wont_be_empty
      groups_all.must_include group
      # Delete
      group.destroy
      proc { @service.groups.find_by_id group_hash[:groupid] }.must_raise Excon::Errors::InternalServerError
    end
  end

  it 'CRUD roles' do
    VCR.use_cassette('crud_roles') do
      role_hash = {:roleid => 'PVETestAuditor'}
      # Create 1st time
      @service.roles.create(role_hash) 
      # Find by id
      role = @service.roles.find_by_id role_hash[:roleid]
      role.wont_be_nil
      # # Create 2nd time must fails
      proc do
        @service.roles.create(role_hash)
      end.must_raise Excon::Errors::InternalServerError
      # # Update
      role.privs = 'Datastore.Audit Sys.Audit VM.Audit'
      role.update
      # # all groups
      roles_all = @service.roles.all
      roles_all.wont_be_nil
      roles_all.wont_be_empty
      roles_all.must_include role
      # Delete
      role.destroy
      proc { @service.roles.find_by_id role_hash[:roleid] }.must_raise Excon::Errors::InternalServerError
    end
  end

  it 'CRUD domains' do
    VCR.use_cassette('crud_domains') do
      ldap_hash = {
        :realm => 'LDAP',  
        :type  => 'ldap',    
        :base_dn => 'ou=People,dc=ldap-test,dc=com',
        :user_attr => 'LDAP',
        :server1 => 'localhost',
        :port => 389,
        :default => 0,
        :secure => 0
      }
      ad_hash = {
        :realm => 'ActiveDirectory',  
        :type  => 'ad',    
        :domain => 'proxmox.com',
        :server1 => 'localhost',
        :port => 389,
        :default => 0,
        :secure => 0
      }
      # Create 1st time
      @service.domains.create(ldap_hash) 
      # Find by id
      ldap = @service.domains.find_by_id ldap_hash[:realm]
      ldap.wont_be_nil
      # Create 1st time
      @service.domains.create(ad_hash)
      # # Create 2nd time must fails
      proc do
        @service.domains.create(ldap_hash)
      end.must_raise Excon::Errors::InternalServerError
      # # Create 2nd time must fails
      proc do
        @service.domains.create(ad_hash)
      end.must_raise Excon::Errors::InternalServerError
      # # Update
      ldap.type.comment = 'Test domain LDAP'
      ldap.type.tfa = 'type=oath,step=30,digits=8'
      ldap.update 
      # Find by id
      ad = @service.domains.find_by_id ad_hash[:realm]
      ad.wont_be_nil
      ad.type.tfa = 'type=yubico,id=1,key=2,url=http://localhost'
      ad.update
      # # all groups
      domains_all = @service.domains.all
      domains_all.wont_be_nil
      domains_all.wont_be_empty
      domains_all.must_include ldap
      domains_all.must_include ad
      # Delete
      ldap.destroy
      ad.destroy
      proc { @service.domains.find_by_id ldap_hash[:realm] }.must_raise Excon::Errors::InternalServerError
      proc { @service.domains.find_by_id ad_hash[:realm] }.must_raise Excon::Errors::InternalServerError
    end
  end


end
