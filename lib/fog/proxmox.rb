require "fog/proxmox/version"
require 'fog/core'
require 'fog/xml'
require 'fog/json'

module Fog

module Fog
  module CDN
    autoload :Proxmox,  File.expand_path('../proxmox/cdn', __FILE__)
  end

  module Compute
    autoload :Proxmox, File.expand_path('../proxmox/compute', __FILE__)
  end

  module DNS
    autoload :Proxmox, File.expand_path('../proxmox/dns', __FILE__)
  end

  module Storage
    autoload :Proxmox, File.expand_path('../proxmox/storage', __FILE__)
end

  module Proxmox
    extend Fog::Provider
    # Your code goes here...
  end
end
