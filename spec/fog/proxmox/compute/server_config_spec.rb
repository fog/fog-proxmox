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
require 'fog/proxmox'
require 'fog/proxmox/compute/models/server_config'

describe 'Fog::Proxmox::Compute::ServerConfig' do
  it 'declares additional container config attributes so they round-trip on read' do
    %i[features tags protection timezone hookscript debug].each do |attr|
      _(Fog::Proxmox::Compute::ServerConfig.attributes).must_include attr
    end
  end

  it 'populates the additional container attributes from a config response' do
    config = Fog::Proxmox::Compute::ServerConfig.new(
      vmid: 100,
      service: Object.new,
      features: 'nesting=1,keyctl=1',
      tags: 'prod;db',
      protection: 1,
      timezone: 'Europe/Prague',
      hookscript: 'local:snippets/hook.pl',
      debug: 1
    )
    _(config.features).must_equal 'nesting=1,keyctl=1'
    _(config.tags).must_equal 'prod;db'
    _(config.protection).must_equal 1
    _(config.timezone).must_equal 'Europe/Prague'
    _(config.hookscript).must_equal 'local:snippets/hook.pl'
    _(config.debug).must_equal 1
  end
end
