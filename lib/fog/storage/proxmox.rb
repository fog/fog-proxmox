# frozen_string_literal: true

module Fog
  module Storage
    # Procmox storage service
    class Proxmox < Fog::Service
      # Models
      model_path 'fog/storage/proxmox/models'
    end
  end
end
