# frozen_string_literal: true

# Copyright 2018 Tristan Robert

# This file is part of Fog::Proxmox.

# Fog::Proxmox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Fog::Proxmox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Fog::Proxmox. If not, see <http://www.gnu.org/licenses/>.

require 'fog/json'
require 'fog/proxmox/variables'
require 'fog/proxmox/json'

module Fog
  module Proxmox
    # Core module
    module Core
      attr_accessor :pve_ticket
      attr_reader :pve_csrftoken
      attr_reader :pve_username
      attr_reader :deadline
      attr_reader :principal

      # fallback
      def self.not_found_class
        Fog::Proxmox::Compute::NotFound
      end

      def initialize_identity(options)
        @principal = nil
        @pve_ticket = nil
        Fog::Proxmox::Variables.to_variables(self, options, 'pve')
        @pve_uri = URI.parse(@pve_url)
        missing_credentials = []
        missing_credentials << :pve_username unless @pve_username

        unless @pve_ticket
          missing_credentials << :pve_password unless @pve_password
        end

        raise ArgumentError, "Missing required arguments: #{missing_credentials.join(', ')}" unless missing_credentials.empty?
      end

      def credentials
        options = {
          provider: 'proxmox',
          pve_url: @pve_uri.to_s,
          pve_ticket: @pve_ticket,
          pve_csrftoken: @pve_csrftoken,
          pve_username: @pve_username
        }
        pve_options.merge options
      end

      def reload
        @connection.reset
      end

      private

      def request(params)
        retried = false
        begin
          response = @connection.request(params.merge(
                                           headers: headers(params[:method], params[:headers])
                                         ))
        rescue Excon::Errors::Unauthorized => e
          # token expiration and token renewal possible
          if e.response.body != 'Bad username or password' && !retried
            authenticate
            retried = true
            retry
          # bad credentials or token renewal not possible
          else
            raise e
          end
        rescue Excon::Errors::HTTPStatusError => e
          raise case e
                when Excon::Errors::NotFound
                  self.class.not_found_class.slurp(e)
                else
                  e
                end
        end
        Fog::Proxmox::Json.get_data(response)
      end

      def headers(method, additional_headers)
        additional_headers ||= {}
        headers_hash = { 'Accept' => 'application/json' }
        # CSRF token is required to PUT, POST and DELETE http requests
        headers_hash.store('CSRFPreventionToken', @pve_csrftoken) if %w[PUT POST DELETE].include? method
        # ticket must be present in cookie
        headers_hash.store('Cookie', "PVEAuthCookie=#{@pve_ticket}") if @pve_ticket
        headers_hash.merge additional_headers
        headers_hash
      end

      def pve_options
        Fog::Proxmox::Variables.to_hash(self, 'pve')
      end

      def authenticate
        options = pve_options
        @pve_ticket = options[:pve_ticket]
        Fog::Proxmox.authenticate(options, @connection_options)
        @principal = Fog::Proxmox.credentials
        @pve_username = Fog::Proxmox.credentials[:username]
        @pve_ticket = Fog::Proxmox.credentials[:ticket]
        @pve_deadline = Fog::Proxmox.credentials[:deadline]
        @pve_csrftoken = Fog::Proxmox.credentials[:csrftoken]

        @host       = @pve_uri.host
        @api_path   = @pve_uri.path
        @api_path.sub!(/\/$/, '')
        @port       = @pve_uri.port
        @scheme     = @pve_uri.scheme

        true
      end
    end
  end
end
