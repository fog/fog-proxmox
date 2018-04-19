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

# frozen_string_literal: true

require 'minitest/autorun'
require 'vcr'
require 'fog/core'
require 'fog/proxmox'
require 'simplecov'

SimpleCov.start do
  add_group "Identity", "lib/fog/identity"
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/proxmox'
  c.hook_into :webmock
  c.debug_logger = nil # use $stderr to debug
end