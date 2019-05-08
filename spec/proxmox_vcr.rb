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

# frozen_string_literal: true

# There are basically two modes of operation for these specs.
#
# 1. ENV[PVE_URL] exists: talk to an actual Proxmox server and record HTTP
#    traffic in VCRs at "spec/debug" (credentials are read from the conventional
#    environment variables: PVE_URL, PVE_USERNAME, PVE_PASSWORD)
# 2. otherwise (Travis etc.): use VCRs at "spec/fixtures/proxmox/#{service}"

require 'vcr'

class ProxmoxVCR
  attr_reader :username,
              :password,
              :ticket,
              :csrftoken,
              :service,
              :url,
              :path,
              :deadline

  def initialize(options)
    @vcr_directory = options[:vcr_directory]
    @service_class = options[:service_class]
    @connection_options = options[:connection_options] || {}

    use_recorded = !ENV.key?('PVE_URL') || ENV['USE_VCR'] == 'true'

    if use_recorded
      Fog.interval = 0
      @url  = 'https://192.168.56.101:8006/api2/json'
    else
      @url  = ENV['PVE_URL']
    end

    VCR.configure do |config|
      config.allow_http_connections_when_no_cassette = true
      if use_recorded
        config.cassette_library_dir = ENV['SPEC_PATH'] || @vcr_directory
        config.default_cassette_options = { record: :none }
        config.default_cassette_options[:match_requests_on] = %i[method uri body]
      else
        config.cassette_library_dir = 'spec/debug'
        config.default_cassette_options = { record: :all }
      end
      config.hook_into :webmock
      config.debug_logger = nil # use $stderr to debug
    end

    # ignore enterprise proxy
    @connection_options[:disable_proxy] = true if ENV['DISABLE_PROXY'] == 'true'

    # ignore dev certificates on servers
    @connection_options[:ssl_verify_peer] = false if ENV['SSL_VERIFY_PEER'] == 'false'

    VCR.use_cassette('identity_ticket') do
      Fog::Proxmox.clear_credentials

      @username  = 'root@pam'
      @password  = 'proxmox01'
      # ticket recorded in identity_ticket.yml
      @ticket    = 'PVE:root@pam:5AB4B38A::m5asyATnV66Htv+Z2QYNu+KuqZDsR1t3fCViuu0bTAWYfU85zdUY2dF9lJXa7soWlaZ3tZriTxC7d+nhMq9Fq8hCRlNG4ntsEw/CzeuS50phSvq4Phx1uZVV0KjkdcVP1X0J50e42Zfr5hzptiO+cD68OF2GG0GaboQ/MV+PA5IxojYojQe1w6yjjzreZhiZYy9zq1W5CW23yIt5pPWk9oFxLNUHU1I2+jqMCOeE40VhivCUEslusD0ZdoA3tkIWJ504rKQJrJIsq1zi6LIpGsktkbUPxHwSgnftQs0IPRuP5HGaz1g9FSW1IUpC8iCHqEV6re+Pb9Yz+G1G7+G0TQ=='
      @csrftoken = '5AB4B38A:J+3XBmYsJqR7F+18kqbMhj6I/SM'

      unless use_recorded
        @username = ENV['PVE_USERNAME'] || options[:username] || @username
        @password = ENV['PVE_PASSWORD'] || options[:password] || @password
        @ticket = ENV['PVE_TICKET'] || options[:ticket] || @ticket
        @csrftoken = ENV['PVE_CSRFTOKEN'] || options[:csrftoken] || @csrftoken
      end

      connection_params = {
        pve_url: @url,
        pve_username: @username,
        pve_password: @password,
        pve_ticket: @ticket,
        pve_csrftoken: @csrftoken,
        connection_options: @connection_options
      }

      @service = @service_class.new(connection_params)
    end
  end
end
