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

# There are basically two modes of operation for these specs.
#
# 1. ENV[PVE_URL] exists: talk to an actual Proxmox server and record HTTP
#    traffic in VCRs at "spec/debug" (credentials are read from the conventional
#    environment variables: PVE_URL, PVE_USERNAME, PVE_PASSWORD)
# 2. otherwise (under Travis etc.): use VCRs at "spec/fixtures/proxmox/#{service}"

require 'vcr'

class ProxmoxVCR

  attr_reader :username,
              :password,
              :ticket,
              :csrftoken,
              :service,
              :proxmox_url,
              :proxmox_path,
              :expires

  def initialize(options)
     @vcr_directory = options[:vcr_directory]
     @service_class = options[:service_class]

    use_recorded = !ENV.key?('PVE_URL') || ENV['USE_VCR'] == 'true'

    if use_recorded
      Fog.interval  = 0
      @proxmox_url  = 'https://172.26.49.146:8006/api2/json'
      @proxmox_path = '/access/ticket'
    else 
      @proxmox_url  = ENV['PVE_URL']
      @proxmox_path = ENV['PVE_PATH']
    end

    VCR.configure do |config|
      config.allow_http_connections_when_no_cassette = true
      if use_recorded
        config.cassette_library_dir = ENV['SPEC_PATH'] || @vcr_directory
        config.default_cassette_options = {:record => :none}
        config.default_cassette_options.merge! :match_requests_on => [:method, :uri, :body]
      else
        config.cassette_library_dir = "spec/debug"
        config.default_cassette_options = {:record => :all}
      end
      config.hook_into :webmock
      config.debug_logger = $stderr # use $stderr to debug
    end

    # ignore enterprise proxy
    Excon.defaults[:disable_proxy] = true if ENV['DISABLE_PROXY'] == 'true'

    # ignore dev certificates on servers
    Excon.defaults[:ssl_verify_peer] = false if ENV['SSL_VERIFY_PEER'] == 'false'

    VCR.use_cassette('identity_ticket') do
      Fog::Proxmox.clear_token_cache
    
      @username  = 'root@pam'
      @password  = 'proxmox01'
      # ticket recorded in identity_ticket.yml
      @ticket    = 'PVE:root@pam:5AB4B38A::m5asyATnV66Htv+Z2QYNu+KuqZDsR1t3fCViuu0bTAWYfU85zdUY2dF9lJXa7soWlaZ3tZriTxC7d+nhMq9Fq8hCRlNG4ntsEw/CzeuS50phSvq4Phx1uZVV0KjkdcVP1X0J50e42Zfr5hzptiO+cD68OF2GG0GaboQ/MV+PA5IxojYojQe1w6yjjzreZhiZYy9zq1W5CW23yIt5pPWk9oFxLNUHU1I2+jqMCOeE40VhivCUEslusD0ZdoA3tkIWJ504rKQJrJIsq1zi6LIpGsktkbUPxHwSgnftQs0IPRuP5HGaz1g9FSW1IUpC8iCHqEV6re+Pb9Yz+G1G7+G0TQ=='
      @csrftoken = '5AB4B38A:J+3XBmYsJqR7F+18kqbMhj6I/SM'
      @expires   = Time.now + 2*60*60

      unless use_recorded
        @username   = ENV['PVE_USERNAME']        || options[:username]   || @username
        @password   = ENV['PVE_PASSWORD']        || options[:password]   || @password
        @ticket     = ENV['PVE_TICKET']          || options[:ticket]     || @ticket
        @csrftoken  = ENV['PVE_CSRFTOKEN']       || options[:csrftoken]  || @csrftoken
        @expires    = ENV['PVE_TICKET_EXPIRES']  || options[:expires]    || @expires
      end

      connection_options = {
        :proxmox_url            => @proxmox_url,
        :proxmox_path           => @proxmox_path, 
        :proxmox_username       => @username, 
        :proxmox_password       => @password, 
        :proxmox_ticket         => @ticket, 
        :proxmox_csrftoken      => @csrftoken, 
        :proxmox_ticket_expires => @expires
      }

      @service = @service_class.new(connection_options)   

    end
  end

end
