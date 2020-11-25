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
        module Auth
            module Token
                class UserToken
                    include Fog::Proxmox::Auth::Token

                    NAME = 'user_token'

                    class URIError < RuntimeError; end

                    def auth_method
                        'GET'
                    end

                    def auth_path(params = {})
                        raise URIError, 'URI params is required' if params.nil? || params.empty?
                        raise URIError, 'proxmox_userid is required' if params[:proxmox_userid].nil? || params[:proxmox_userid].empty?
                        raise URIError, 'proxmox_tokenid is required' if params[:proxmox_tokenid].nil? || params[:proxmox_tokenid].empty?
                        "/access/users/#{URI.encode_www_form_component(params[:proxmox_userid])}/token/#{params[:proxmox_tokenid]}"
                    end

                    def auth_body(params = {})
                        ''
                    end                

                    def headers(method = 'GET', params = {}, additional_headers = {})
                        raise URIError, 'proxmox_token is required' if params[:proxmox_token].nil? || params[:proxmox_token].empty?
                        headers_hash = {}
                        headers_hash.store('Authorization', "PVEAPIToken=#{params[:proxmox_userid]}!#{params[:proxmox_tokenid]}=#{params[:proxmox_token]}") unless params.empty?
                        headers_hash.merge! additional_headers
                        headers_hash
                    end

                    def build_credentials(data)
                        @expires = data['expire']
                    end

                    def missing_credentials(options)
                        missing_credentials = []
                        missing_credentials << :proxmox_userid unless options[:proxmox_userid]
                        missing_credentials << :proxmox_tokenid unless options[:proxmox_tokenid]
                        missing_credentials << :proxmox_token unless options[:proxmox_token]
                        raise ArgumentError, "Missing required arguments: #{missing_credentials.join(', ')}" unless missing_credentials.empty?
                    end
                end
            end
        end
    end
end
