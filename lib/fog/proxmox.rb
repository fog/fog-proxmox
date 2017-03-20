require "fog/proxmox/version"
require 'fog/core'
require 'fog/json'

module Fog

  module Compute
    autoload :Proxmox, File.expand_path('../proxmox/compute', __FILE__)
  end

  module Storage
    autoload :Proxmox, File.expand_path('../proxmox/storage', __FILE__)
  end

  module Proxmox
    extend Fog::Provider
    # Your code goes here...
  end
end
