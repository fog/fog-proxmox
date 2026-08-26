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
require 'fog/proxmox/storage/requests/upload_iso'

real_storage_class = Fog::Proxmox::Storage::Real

describe Fog::Proxmox::Storage::Real do
  it 'loads the upload request and reuses an authenticated compute connection' do
    auth_request = WebMock.stub_request(:get, 'https://pve.example.test/api2/json/access/users/root@pam/token/test')
                          .to_return(body: '{"data":{"expire":0}}')
    compute = Fog::Proxmox::Compute.new(
      proxmox_url: 'https://pve.example.test/api2/json',
      proxmox_auth_method: 'user_token',
      proxmox_userid: 'root@pam',
      proxmox_tokenid: 'test',
      proxmox_token: 'test-token'
    )
    storage = Fog::Proxmox::Storage.new(compute.config)

    _(storage).must_be_kind_of real_storage_class
    _(storage).must_respond_to :upload_iso
    _(storage.instance_variable_get(:@connection)).must_be_same_as compute.instance_variable_get(:@connection)
    _(storage.instance_variable_get(:@auth_token)).must_be_same_as compute.instance_variable_get(:@auth_token)
    _(compute).wont_respond_to :upload_iso
  ensure
    WebMock.remove_request_stub(auth_request)
  end

  describe '#upload_iso' do
    it 'streams a multipart ISO upload request' do
      service = real_storage_class.allocate
      iso_data = "cloud-init\x00\xFF".b
      source = StringIO.new(iso_data)
      read_lengths = []
      file = Object.new
      file.define_singleton_method(:size) { source.size }
      file.define_singleton_method(:rewind) { source.rewind }
      file.define_singleton_method(:read) do |length|
        read_lengths << length
        source.read(length)
      end
      source.read
      request_options = nil

      service.stub(:request, lambda { |options|
        request_options = options
        'uploaded'
      }) do
        result = service.upload_iso(
          { node: 'pve', storage: 'local' },
          { filename: 'vm-cloudinit.iso', file: file }
        )

        _(result).must_equal 'uploaded'
      end

      _(request_options[:expects]).must_equal [200]
      _(request_options[:method]).must_equal 'POST'
      _(request_options[:path]).must_equal 'nodes/pve/storage/local/upload'
      _(request_options[:headers]['Content-Type']).must_match(%r{\Amultipart/form-data; boundary=})
      body = request_options[:body]
      chunks = []
      while (chunk = body.read(4))
        chunks << chunk
      end
      encoded_body = chunks.join

      _(body).must_be_kind_of Fog::Proxmox::MultipartBody
      _(body.size).must_equal encoded_body.bytesize
      _(encoded_body).must_include %(name="content"#{Excon::CR_NL}#{Excon::CR_NL}iso)
      _(encoded_body).must_include %(name="filename"; filename="vm-cloudinit.iso")
      _(encoded_body).must_include 'Content-Type: application/octet-stream'
      _(encoded_body).must_include iso_data
      _(read_lengths).wont_be_empty
      _(read_lengths.all? { |length| length <= 4 }).must_equal true

      body.rewind
      _(body.read(body.size)).must_equal encoded_body
    end

    it 'rejects an unsafe filename' do
      service = real_storage_class.allocate

      error = _(proc do
        service.upload_iso(
          { node: 'pve', storage: 'local' },
          { filename: "bad\r\nname.iso", file: StringIO.new('iso') }
        )
      end).must_raise ArgumentError

      _(error.message).must_match(/Invalid ISO filename/)
    end

    it 'accepts an uppercase ISO extension' do
      service = real_storage_class.allocate
      service.stub(:request, 'uploaded') do
        result = service.upload_iso(
          { node: 'pve', storage: 'local' },
          { filename: 'installer.ISO', file: StringIO.new('iso') }
        )

        _(result).must_equal 'uploaded'
      end
    end
  end

  describe '#request' do
    it 'merges caller headers without overriding authentication headers' do
      service = real_storage_class.allocate
      auth_token = Object.new
      auth_token.define_singleton_method(:headers) do |_method, _params, _additional_headers|
        { 'Authorization' => 'PVEAPIToken=test' }
      end

      request_options = nil
      response = Struct.new(:body).new('{"data":"uploaded"}')
      connection = Object.new
      connection.define_singleton_method(:request) do |options|
        request_options = options
        response
      end

      service.instance_variable_set(:@auth_token, auth_token)
      service.instance_variable_set(:@connection, connection)
      service.instance_variable_set(:@expires, nil)
      service.instance_variable_set(:@path, '/api2/json')

      result = service.send(
        :request,
        method: 'POST',
        path: 'nodes/pve/storage/local/upload',
        headers: {
          'Authorization' => 'caller-supplied-token',
          'Content-Type' => 'multipart/form-data; boundary=test'
        }
      )

      _(result).must_equal 'uploaded'
      _(request_options[:headers]).must_equal(
        'Authorization' => 'PVEAPIToken=test',
        'Content-Type' => 'multipart/form-data; boundary=test'
      )
    end
  end
end
