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

describe Fog::Identity::Proxmox do
  before :all do
    @proxmox_vcr = ProxmoxVCR.new(
      vcr_directory: 'spec/fixtures/proxmox/identity',
      service_class: Fog::Identity::Proxmox
    )
    @service = @proxmox_vcr.service
    @pve_url = @proxmox_vcr.url
    @username = @proxmox_vcr.username
    @password = @proxmox_vcr.password
    @ticket = @proxmox_vcr.ticket
    @csrftoken = @proxmox_vcr.csrftoken
  end

  it 'authenticates with username and password' do
    VCR.use_cassette('auth') do
      identity = Fog::Identity::Proxmox.new(
        pve_username: @username,
        pve_password: @password,
        pve_url: @pve_url.to_s
      )
      identity.wont_be_nil
    end
  end

  it 'verifies ticket with path and privs' do
    VCR.use_cassette('auth') do
      principal = { username: @username, password: @password, privs: ['User.Modify'], path: 'access', otp: 'proxmox01' }
      permissions = @service.check_permissions(principal)
      permissions.wont_be_nil
      permissions.wont_be_empty
      permissions['username'].must_equal @username
      permissions['cap'].wont_be_empty
    end
  end

  it 'reads server version' do
    VCR.use_cassette('read_version') do
      version = @service.read_version
      version.wont_be_nil
      version.include? 'version'
    end
  end

  it 'CRUD users' do
    VCR.use_cassette('users') do
      bob_hash = {
        userid: 'bobsinclar@pve',
        password: 'bobsinclar1',
        firstname: 'Bob',
        lastname: 'Sinclar',
        email: 'bobsinclar@proxmox.com'
      }
      # Create 1st time
      @service.users.create(bob_hash)
      # Find by id
      bob = @service.users.get bob_hash[:userid]
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
      @service.groups.create(groupid: 'group1')
      @service.groups.create(groupid: 'group2')
      bob.groups = %w[group1 group2]
      bob.update
      # change bob's password
      bob.password = 'bobsinclar2'
      bob.change_password
      # disabled users
      users_disabled = @service.users.all('enabled' => 0)
      users_disabled.wont_be_nil
      users_disabled.wont_be_empty
      users_disabled.must_include bob
      # Delete
      bob.destroy
      group1 = @service.groups.get 'group1'
      group1.destroy
      group2 = @service.groups.get 'group2'
      group2.destroy
      bob = @service.users.get bob_hash[:userid]
      bob.must_be_nil
    end
  end

  it 'CRUD groups' do
    VCR.use_cassette('groups') do
      group_hash = { groupid: 'group1' }
      # Create 1st time
      @service.groups.create(group_hash)
      # Find by id
      group = @service.groups.get group_hash[:groupid]
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
      group1 = @service.groups.get group_hash[:groupid]
      group1.must_be_nil
    end
  end

  it 'CRUD roles' do
    VCR.use_cassette('roles') do
      role_hash = { roleid: 'PVETestAuditor' }
      # Create 1st time
      @service.roles.create(role_hash)
      # Find by id
      role = @service.roles.get role_hash[:roleid]
      role.wont_be_nil
      # Create 2nd time must fails
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
      role = @service.roles.get role_hash[:roleid]
      role.must_be_nil
    end
  end

  it 'CRUD domains' do
    VCR.use_cassette('domains') do
      ldap_hash = {
        realm: 'LDAP',
        type: 'ldap',
        base_dn: 'ou=People,dc=ldap-test,dc=com',
        user_attr: 'LDAP',
        server1: 'localhost',
        port: 389,
        default: 0,
        secure: 0
      }
      ad_hash = {
        realm: 'ActiveDirectory',
        type: 'ad',
        domain: 'proxmox.com',
        server1: 'localhost',
        port: 389,
        default: 0,
        secure: 0
      }
      # Create 1st time
      @service.domains.create(ldap_hash)
      # Find by id
      ldap = @service.domains.get ldap_hash[:realm]
      ldap.wont_be_nil
      # Create 1st time
      @service.domains.create(ad_hash)
      # Create 2nd time must fails
      proc do
        @service.domains.create(ldap_hash)
      end.must_raise Excon::Errors::InternalServerError
      # # Create 2nd time must fails
      proc do
        @service.domains.create(ad_hash)
      end.must_raise Excon::Errors::InternalServerError
      # Update
      ldap.type.comment = 'Test domain LDAP'
      ldap.type.tfa = 'type=oath,step=30,digits=8'
      ldap.update
      # Find by id
      ad = @service.domains.get ad_hash[:realm]
      # ad.wont_be_nil
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
      ldap = @service.domains.get ldap_hash[:realm]
      ldap.must_be_nil
      ad = @service.domains.get ad_hash[:realm]
      ad.must_be_nil
    end
  end

  it 'adds or removes permissions' do
    VCR.use_cassette('permissions') do
      # Add ACL to users
      bob_hash = {
        userid: 'bobsinclar@pve',
        password: 'bobsinclar1',
        firstname: 'Bob',
        lastname: 'Sinclar',
        email: 'bobsinclar@proxmox.com'
      }
      @service.roles.create(roleid: 'PVETestAdmin', privs: 'User.Modify,Group.Allocate')
      role = @service.roles.get('PVETestAdmin')
      role.wont_be_nil
      @service.users.create(bob_hash)
      bob = @service.users.get bob_hash[:userid]
      bob.wont_be_nil
      permission = @service.permissions.create(type: 'user', roleid: role.roleid, path: '/access', ugid: bob.userid)
      permission.wont_be_nil
      # Read all permissions
      permissions = @service.permissions.all
      permissions.wont_be_empty
      permissions.must_include permission
      # Remove ACL to users
      permissions.destroy(type: 'user', roleid: role.roleid, path: '/access', ugid: bob.userid)
      permission = @service.permissions.get('user', role.roleid, '/access', bob.userid)
      permission.must_be_nil
      bob = @service.users.get bob_hash[:userid]
      bob.destroy
      # Add ACL to groups
      group1 = @service.groups.create(groupid: 'group1', comment: 'Group 1')
      permission = @service.permissions.create(type: 'group', roleid: role.roleid, path: '/access', ugid: group1.groupid)
      permission.wont_be_nil
      # Read new permission
      permissions = @service.permissions.all
      permissions.wont_be_empty
      permissions.must_include permission
      # Remove ACL to groups
      permissions.destroy(type: 'group', roleid: role.roleid, path: '/access', ugid: group1.groupid)
      permissions = @service.permissions.all
      permissions.must_be_empty
      group1.destroy
      role.destroy
    end
  end

  it 'CRUD pools' do
    VCR.use_cassette('pools') do
      pool_hash = { poolid: 'pool1' }
      # Create 1st time
      @service.pools.create(pool_hash)
      # Find by id
      pool = @service.pools.get pool_hash[:poolid]
      pool.wont_be_nil
      # Create 2nd time must fails
      proc do
        @service.pools.create(pool_hash)
      end.must_raise Excon::Errors::InternalServerError
      # Update
      # Add comment
      pool.comment = 'Pool 1'
      pool.update
      # Add storage as member
      pool.add_server 100 # do nothing if server does not exist
      pool.add_storage 'local-lvm'
      # all pools
      pools_all = @service.pools.all
      pools_all.wont_be_nil
      pools_all.wont_be_empty
      pools_all.must_include pool
      # Delete
      pool.remove_server 100
      pool.remove_storage 'local-lvm'
      pool.destroy
      pool = @service.pools.get pool_hash[:poolid]
      pool.must_be_nil
    end
  end
end
