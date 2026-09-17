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
require 'fog/proxmox/compute/models/ha_resource'

describe 'Fog::Proxmox::Compute::HaResource' do
  # A HA resource can only be built with a service (fog requires one). This
  # minimal stub records the request it is handed so we can assert on it.
  def build(method, attrs = {})
    calls = []
    service = Object.new
    service.define_singleton_method(method) do |*args|
      calls << args
      nil
    end
    resource = Fog::Proxmox::Compute::HaResource.new(
      { sid: 'ct:100', type: 'ct', service: service }.merge(attrs)
    )
    [resource, calls]
  end

  it 'declares the HA resource attributes' do
    %i[sid type state group max_relocate max_restart comment digest].each do |attr|
      _(Fog::Proxmox::Compute::HaResource.attributes).must_include attr
    end
  end

  it 'drops nil params from the request body' do
    resource, = build(:create_ha_resource, state: 'started')
    params = resource.send(:request_params)
    _(params[:sid]).must_equal 'ct:100'
    _(params[:type]).must_equal 'ct'
    _(params[:state]).must_equal 'started'
    _(params.key?(:group)).must_equal false
    _(params.key?(:comment)).must_equal false
  end

  it 'save posts sid and type to create_ha_resource' do
    resource, calls = build(:create_ha_resource, state: 'started', group: 'prod')
    resource.save
    body = calls.first.first
    _(body[:sid]).must_equal 'ct:100'
    _(body[:type]).must_equal 'ct'
    _(body[:state]).must_equal 'started'
    _(body[:group]).must_equal 'prod'
  end

  it 'update omits the create-only sid and type from the request body' do
    resource, calls = build(:update_ha_resource, state: 'stopped', group: 'prod')
    resource.update
    path_params, body = calls.first
    _(path_params).must_equal(sid: 'ct:100')
    _(body.key?(:sid)).must_equal false
    _(body.key?(:type)).must_equal false
    _(body[:state]).must_equal 'stopped'
    _(body[:group]).must_equal 'prod'
  end

  it 'destroy deletes by sid' do
    resource, calls = build(:delete_ha_resource)
    resource.destroy
    _(calls.first.first).must_equal(sid: 'ct:100')
  end
end
