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
      attr_accessor :auth_token
      attr_reader :csrf_token
      attr_reader :current_user

      # fallback
      def self.not_found_class
        Fog::Compute::Proxmox::NotFound
      end

      def initialize_identity(options)

        # Create @proxmox_* instance variables from all :proxmox_* options
        options.select { |x| x.to_s.start_with? 'proxmox' }.each do |proxmox_param, value|
          instance_variable_set "@#{proxmox_param}".to_sym, value
        end

        ticket = options[:proxmox_ticket]
        @with_auth_token = !ticket.to_s.empty?
        @auth_token = ticket
        @proxmox_must_reauthenticate = false

        @proxmox_uri = URI.parse(options[:proxmox_url])
        path_auth = '/api2/json/access/ticket'

        if @with_auth_token
          @proxmox_can_reauthenticate = false
        else
          missing_credentials = []

          missing_credentials << :proxmox_username unless @proxmox_username
          missing_credentials << :proxmox_password unless @proxmox_password
          raise ArgumentError, "Missing required arguments: #{missing_credentials.join(', ')}" unless missing_credentials.empty?
          @proxmox_can_reauthenticate = true
        end

        @current_user = options[:current_user]
        @is_authenticated = @current_user!=nil
      end

      def credentials
        options = {
          :provider                    => 'proxmox',
          :proxmox_url                 => @proxmox_uri.to_s,
          :proxmox_auth_token          => @auth_token,
          :current_user                => @current_user
        }
        proxmox_options.merge options
      end

      def reload
        @connection.reset
      end

      private

      def request(params, parse_json = true)
        retried = false
        begin
          response = @connection.request(params.merge(
                                           :headers => headers(params.delete(:headers)),
                                           :cookies => cookies,
                                           :path    => "#{@path}/#{params[:path]}"
          ))
        rescue Excon::Errors::Unauthorized => error
          # token expiration and token renewal possible
          if error.response.body != 'Bad username or password' && @proxmox_can_reauthenticate && !retried
            @proxmox_must_reauthenticate = true
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

        body = response.body

        if !body.empty? && response.get_header('Content-Type').match('application/json')
          body = Fog::JSON.decode(body) if parse_json && !params[:raw_body]
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
          headers_hash.merge({'CSRFPreventionToken' => @csrf_token})
        end
        headers_hash.merge!(additional_headers)
      end

      def cookies
        cookies_hash = {}
        # if authenticated ticket must be present in cookie
        if @with_auth_token
          cookies_hash = {'PVEAuthCookie' => @ticket}
        end
        cookies_hash
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
        if !@is_authenticated

          options = proxmox_options

          options[:proxmox_auth_token] = @proxmox_must_reauthenticate ? nil : @auth_token

          credentials = Fog::Proxmox.authenticate(options, @connection_options)

          @current_user = credentials[:user]

          @proxmox_must_reauthenticate = false
          @auth_token = credentials[:ticket]
          @csrf_token = credentials[:csrftoken]
        end

        @host   = @proxmox_uri.host
        @path   = @proxmox_uri.path
        @path.sub!(%r{/$}, '')
        @port   = @proxmox_uri.port
        @scheme = @proxmox_uri.scheme

        true
      end

    end
  end
end