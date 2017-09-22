# frozen_string_literal: true

module Fog
  module Proxmox
    # Core module
    module Core
      attr_accessor :auth_token
      attr_reader :csrf_token
      attr_reader :current_user

      def credentials
        options = {
          provider: 'proxmox',
          proxmox_url: @proxmox_url,
          openstack_auth_token: @auth_token,
          current_user: @current_user
        }
        proxmox_options.merge options
      end

      def auhtenticate; end
    end
  end
end
