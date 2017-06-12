require "fog/proxmox/version"
require 'fog/core'
require 'fog/json'

module Fog

  module Compute
    autoload :Proxmox, File.expand_path('../compute/proxmox', __FILE__)
  end

  module Storage
    autoload :Proxmox, File.expand_path('../storage/proxmox', __FILE__)
  end

  module Network
    autoload :Proxmox, File.expand_path('../network/proxmox', __FILE__)
  end

  module Proxmox
    extend Fog::Provider
    service(:compute, 'Compute')
    service(:storage, 'Storage')
    service(:network, 'Network')
     def self.authenticate(options, connection_options = {})
       url = options[:proxmox_url]
       username = options[:username]
    end
  end
end
