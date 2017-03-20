require "fog/core"
require "fog/proxmox"
require 'minitest/autorun'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/proxmxox'
  c.hook_into :webmock
  c.debug_logger = nil # use $stderr to debug
end
