# frozen_string_literal: true

require 'fog/compute/proxmox/models'
module Fog
  module Compute
    class Proxmox
      # Real create_vm class
      class Real
        def create(node, vmid, options = {}); end

        def delete(node, vmid); end

        def start(node, vmid); end

        def stop(node, vmid); end

        def suspend(node, vmid); end

        def resume(node, vmid); end

        def shutdown(node, vmid); end
      end
      # Mock create_vm class
      class Mock
        def create(node, vmid, options = {}); end

        def delete(node, vmid); end

        def start(node, vmid); end

        def stop(node, vmid); end

        def suspend(node, vmid); end

        def resume(node, vmid); end

        def shutdown(node, vmid); end
      end
    end
  end
end
