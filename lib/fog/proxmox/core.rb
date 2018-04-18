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

# frozen_string_literal: true

require 'fog/json'

module Fog
  module Proxmox
    # Core module
    module Core
      attr_accessor :ticket
      attr_reader :csrf_token
      attr_reader :current_user
      attr_reader :ticket_deadline

      # fallback
      def self.not_found_class
        Fog::Compute::Proxmox::NotFound
      end

      def is_authenticated?
        return !@current_user.nil?
      end

      def initialize_identity(options)

        # Create @proxmox_* instance variables from all :proxmox_* options
        options.select { |x| x.to_s.start_with? 'proxmox' }.each do |proxmox_param, value|
          instance_variable_set "@#{proxmox_param}".to_sym, value
        end

        @with_ticket = !@proxmox_ticket.nil?
        @is_ticket_valid = !@proxmox_ticket_deadline.nil? && @proxmox_ticket_deadline > Time.now
        @proxmox_must_reauthenticate = false
        @proxmox_uri = URI.parse(@proxmox_url)

        if !@is_ticket_valid
          @proxmox_must_reauthenticate = true
        end

        missing_credentials = []
        missing_credentials << :proxmox_username unless @proxmox_username

        if !@with_ticket
          missing_credentials << :proxmox_password unless @proxmox_password
        end
        
        raise ArgumentError, "Missing required arguments: #{missing_credentials.join(', ')}" unless missing_credentials.empty?

      end

      def credentials
        options = {
          :provider                    => 'proxmox',
          :proxmox_url                 => @proxmox_uri.to_s,
          :proxmox_ticket              => @ticket,
          :proxmox_ticket_deadline     => @ticket_deadline,
          :proxmox_csrftoken           => @csrf_token,
          :proxmox_username            => @current_user
        }
        proxmox_options.merge options
      end

      def reload
        @connection.reset
      end

      private

      def request(params)
        retried = false
        begin
          response = @connection.request(params.merge(
                                           :headers => headers(params[:method],params[:headers]),
                                           :path    => "#{@api_path}/#{params[:path]}"
          ))
        rescue Excon::Errors::Unauthorized => error
          # token expiration and token renewal possible
          if error.response.body != 'Bad username or password' && @proxmox_can_reauthenticate && !retried
            authenticate
            retried = true
            retry
          # bad credentials or token renewal not possible
          else
            raise error
          end
        rescue Excon::Errors::HTTPStatusError => error
          raise case error
                when Excon::Errors::NotFound
                  self.class.not_found_class.slurp(error)
                else
                  error
                end
        end
        response
      end

      def headers(method, additional_headers)
        additional_headers ||= {}
        headers_hash = {
          'Content-Type'        => 'application/json',
          'Accept'              => 'application/json'
        }
        # CSRF token is required to PUT, POST and DELETE http requests
        if ['PUT','POST','DELETE'].include? method
          headers_hash.store('CSRFPreventionToken',@csrf_token)
        end
        # if authenticated ticket must be present in cookie
        if @with_ticket
          headers_hash.store('Cookie',"PVEAuthCookie=#{@ticket}")
        end
        headers_hash.merge additional_headers
        headers_hash
      end

      def proxmox_options
        options = {}
        # Create a hash of (:proxmox_*, value) of all the @proxmox_* instance variables
        instance_variables.select { |x| x.to_s.start_with? '@proxmox' }.each do |proxmox_param|
          option_name = proxmox_param.to_s[1..-1]
          options[option_name.to_sym] = instance_variable_get proxmox_param
        end
        options
      end

      def authenticate
        if !is_authenticated?
          options = proxmox_options
          options[:proxmox_ticket] = @proxmox_must_reauthenticate ? nil : @ticket
          credentials = Fog::Proxmox.authenticate(options, @connection_options)
          @current_user                = credentials[:username]
          @ticket                      = credentials[:ticket]
          @ticket_deadline             = credentials[:ticket_deadline]
          @csrf_token                  = credentials[:csrf_token]
          @proxmox_must_reauthenticate = false
        end

        @host       = @proxmox_uri.host
        @api_path   = @proxmox_uri.path
        @api_path.sub!(%r{/$}, '')
        @port       = @proxmox_uri.port
        @scheme     = @proxmox_uri.scheme

        true
      end

    end
  end
end