# frozen_string_literal: true

# This file is part of Fog::Proxmox.

# Fog::Proxmox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Fog::Proxmox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Fog::Proxmox. If not, see <http://www.gnu.org/licenses/>.

require 'spec_helper'
require 'stringio'
require 'fog/proxmox/compute/models/multipart_body'

multipart_body_class = Fog::Proxmox::MultipartBody

# Match the implementation's compute/models location despite its shared namespace.
describe Fog::Proxmox::MultipartBody do # rubocop:disable RSpec/SpecFilePathFormat
  it 'streams and rewinds all multipart sections' do
    body = multipart_body_class.new('prefix', StringIO.new('file'), 'suffix')

    _(body.size).must_equal 16
    _(body.read(8)).must_equal 'prefixfi'
    _(body.read).must_equal 'lesuffix'
    _(body.read(1)).must_be_nil

    body.rewind
    _(body.read).must_equal 'prefixfilesuffix'
  end

  it 'clears the output buffer and returns nil at EOF' do
    body = multipart_body_class.new('prefix', StringIO.new('file'), 'suffix')
    body.read
    outbuf = String.new('existing')

    _(body.read(1, outbuf)).must_be_nil
    _(outbuf).must_be_empty
  end
end
