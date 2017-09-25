# frozen_string_literal: true

require 'fog/compute/proxmox/models/server'

module Fog
  module Compute
    class Proxmox
      # Servers Collection
      class Servers < Fog::Collection
        model Fog::Compute::Proxmox::Server
      end
    end
  end
end
