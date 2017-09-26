# frozen_string_literal: true

require 'fog/compute/proxmox/models'
module Fog
  module Compute
    class Proxmox
      # Real create_vm class
      class Real
        def create(node, vmid, options = {}); end

        def delete(node, vmid, options = {}); end

        def start(node, vmid, options = {}); end

        def stop(node, vmid, options = {}); end

        def suspend(node, vmid, options = {}); end

        def resume(node, vmid, options = {}); end

        def shutdown(node, vmid, options = {}); end

        def reset(node, vmid, options = {}); end

        def current(node, vmid); end
      end
      # Mock create_vm class
      class Mock
        def create(node, vmid, options = {}); end

        def delete(node, vmid, options = {}); end

        def start(node, vmid, options = {}); end

        def stop(node, vmid, options = {}); end

        def suspend(node, vmid, options = {}); end

        def resume(node, vmid, options = {}); end

        def shutdown(node, vmid, options = {}); end

        def reset(node, vmid, options = {}); end

        def current(node, vmid); end
      end
    end
  end
end
