# frozen_string_literal: true

require 'fog/proxmox/version'
require 'fog/proxmox/core'
require 'fog/core'
require 'fog/json'

module Fog

  #Identity module
  module Identity
    autoload :Proxmox, File.expand_path('../identity/proxmox', __FILE__)
  end
  # Compute module
  module Compute
    autoload :Proxmox, File.expand_path('../compute/proxmox', __FILE__)
  end
  # Storage module
  module Storage
    autoload :Proxmox, File.expand_path('../storage/proxmox', __FILE__)
  end
  # Network module
  module Network
    autoload :Proxmox, File.expand_path('../network/proxmox', __FILE__)
  end

  # Proxmox module
  module Proxmox
    extend Fog::Provider
    service(:identity, 'Identity')
    service(:compute, 'Compute')
    service(:storage, 'Storage')
    service(:network, 'Network')
  end
end
