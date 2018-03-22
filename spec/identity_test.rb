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

require 'test/unit'

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/proxmox'
  c.hook_into :webmock
  c.debug_logger = nil # use $stderr to debug
end

class IdentityVCRTest < Test::Unit::TestCase
    def test_identity_get_ticket
      VCR.use_cassette("identity_ticket") do
        uri = URI('https://172.26.49.155:8006/api2/json/access/ticket')
        params = { :username => 'root@pam', :password => 'proxmox01' }
        p_addr = nil # no proxy     
        http = Net::HTTP.new(uri.host, uri.port, p_addr)
        http.use_ssl = true   
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE # invalid default proxmox certificate 
        request = Net::HTTP::Get.new uri
        response = http.request request # Net::HTTPResponse object
        puts response.body if response.is_a?(Net::HTTPSuccess)
        assert_match(/CSRFPreventionToken ticket username/, response.body)
      end
    end
  end