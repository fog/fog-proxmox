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
  let(:upload_upid) { 'UPID:pve:000008D8:00009E0D:5FBE5DEC:imgcopy::root@pam:' }

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

  def expect_upload(response, error: nil, node: 'pve')
    service.expect(:nil?, false)
    service.expect(:config, :compute_config)
    upload_service.expect(:upload_iso, response) do |path, body|
      _(path).must_equal(node: node, storage: 'local')
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

  def expect_wait(error: nil, node: 'pve', expected_upid: upload_upid)
    tasks = Object.new
    test = self
    tasks.define_singleton_method(:wait_for) do |upid|
      test.assert_equal expected_upid, upid
      test.assert_predicate test.uploaded_file, :closed?
      raise error if error

      true
    end
    nodes = Minitest::Mock.new
    nodes.expect(:get, Struct.new(:tasks).new(tasks), [node])
    service.expect(:nodes, nodes)
    nodes
  end

  it 'uploads to its node and storage, closes the file, and waits before returning the UPID' do
    expect_upload(upload_upid)
    nodes = expect_wait

    _(upload_iso).must_equal upload_upid
    service.verify
    nodes.verify
  end

  it 'polls the node in the returned UPID when it differs from the upload node' do
    storage.node_id = 'test-2'
    upid = 'UPID:test-1:000008D8:00009E0D:5FBE5DEC:upload::root@pam:'
    expect_upload(upid, node: 'test-2')
    nodes = expect_wait(node: 'test-1', expected_upid: upid)

    _(upload_iso).must_equal upid
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

  it 'rejects a UPID with no task owner without polling tasks' do
    expect_upload('UPID::000008D8:00009E0D:5FBE5DEC:imgcopy::root@pam:')

    error = _(proc { upload_iso }).must_raise Fog::Errors::Error
    _(error.message).must_match(/Unexpected upload response/)
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
    expect_upload(upload_upid)
    nodes = expect_wait(error: Fog::Errors::Error.new('Task failed'))

    error = _(proc { upload_iso }).must_raise Fog::Errors::Error
    _(error.message).must_equal 'Task failed'
    service.verify
    nodes.verify
  end
end
