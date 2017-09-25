# frozen_string_literal: true

module Fog
  module Compute
    class Proxmox
      # Node model
      class Node < Fog::Model
        # required
        attribute :name, aliases: 'node'
      end
    end
  end
end
