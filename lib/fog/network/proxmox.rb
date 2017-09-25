# frozen_string_literal: true

module Fog
  module Network
    # Proxmox network service
    class Proxmox < Fog::Service
      # Models
      model_path 'fog/network/proxmox/models'
    end
  end
end
