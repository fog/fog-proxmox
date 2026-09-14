# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'fog/proxmox/attributes'
require 'fog/proxmox/compute/models/volumes'
require 'fog/proxmox/compute/models/storage'

storage_class = Fog::Proxmox::Compute::Storage

describe Fog::Proxmox::Compute::Storage do # rubocop:disable RSpec/SpecFilePathFormat
  let(:service) { Minitest::Mock.new }
  let(:upload_service) { Minitest::Mock.new }
  let(:storage) { storage_class.new(service: service, node_id: 'pve', storage: 'local') }
  let(:iso) { Tempfile.new(['cloudinit', '.iso']) }

  attr_accessor :uploaded_file

  before do
    service.expect(:nil?, false)
    storage
    iso.binmode
    iso.write("cloud-init\x00\xFF".b)
    iso.flush
  end

  after do
    iso.close!
  end

  def expect_upload(response, error: nil)
    service.expect(:nil?, false)
    service.expect(:config, :compute_config)
    upload_service.expect(:upload_iso, response) do |path, body|
      _(path).must_equal(node: 'pve', storage: 'local')
      _(body[:filename]).must_equal File.basename(iso.path)
      self.uploaded_file = body[:file]
      _(uploaded_file.read).must_equal "cloud-init\x00\xFF".b
      raise error if error

      true
    end
  end

  def upload_iso
    factory = lambda do |config|
      _(config).must_equal :compute_config
      upload_service
    end
    Fog::Proxmox::Storage.stub(:new, factory) do
      storage.upload_iso(iso.path)
    end
  ensure
    upload_service.verify
  end

  def expect_wait(error: nil)
    tasks = Object.new
    test = self
    tasks.define_singleton_method(:wait_for) do |upid|
      test.assert_equal 'UPID:upload', upid
      test.assert_predicate test.uploaded_file, :closed?
      raise error if error

      true
    end
    nodes = Minitest::Mock.new
    nodes.expect(:get, Struct.new(:tasks).new(tasks), ['pve'])
    service.expect(:nodes, nodes)
    nodes
  end

  it 'uploads to its node and storage, closes the file, and waits before returning the UPID' do
    expect_upload('UPID:upload')
    nodes = expect_wait

    _(upload_iso).must_equal 'UPID:upload'
    service.verify
    nodes.verify
  end

  it 'rejects an invalid response without polling tasks' do
    expect_upload(nil)

    error = _(proc { upload_iso }).must_raise Fog::Errors::Error
    _(error.message).must_equal 'Unexpected upload response: nil'
    _(uploaded_file.closed?).must_equal true
    service.verify
  end

  it 'closes the file when the upload request fails' do
    expect_upload(nil, error: Fog::Errors::Error.new('Upload failed'))

    error = _(proc { upload_iso }).must_raise Fog::Errors::Error
    _(error.message).must_equal 'Upload failed'
    _(uploaded_file.closed?).must_equal true
  end

  it 'propagates task failures' do
    expect_upload('UPID:upload')
    nodes = expect_wait(error: Fog::Errors::Error.new('Task failed'))

    error = _(proc { upload_iso }).must_raise Fog::Errors::Error
    _(error.message).must_equal 'Task failed'
    service.verify
    nodes.verify
  end
end
