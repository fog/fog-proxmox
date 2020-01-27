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

require 'spec_helper'
require 'fog/proxmox/helpers/ip_helper'

    describe Fog::Proxmox::IpHelper do
            
        let(:ip) do 
            { ip: '192.168.56.100/31' }
        end

        let(:invalid_ip) do 
            { ip: '192.168.56.100/sfsdfsdfdsf' }
        end

        describe '#cidr?' do
            it "192.168.56.100/31 returns true" do
                assert_equal true, Fog::Proxmox::IpHelper.cidr?(ip[:ip])
            end
            it "192.168.56.100/sfsdfsdfdsf returns false" do
                assert_equal false, Fog::Proxmox::IpHelper.cidr?(invalid_ip[:ip])
            end
        end

        describe '#suffix' do
            it "192.168.56.100/31 returns 31" do
                assert_equal '31', Fog::Proxmox::IpHelper.suffix(ip[:ip])
            end
            it "192.168.56.100/sfsdfsdfdsf returns nil" do
                assert_nil Fog::Proxmox::IpHelper.suffix(invalid_ip[:ip])
            end
        end

        describe '#ip' do
            it "192.168.56.100/31 returns 192.168.56.100" do
                assert_equal '192.168.56.100', Fog::Proxmox::IpHelper.ip(ip[:ip])
            end
            it "192.168.56.100/sfsdfsdfdsf returns nil" do
                assert_nil Fog::Proxmox::IpHelper.ip(invalid_ip[:ip])
            end
        end

        describe '#to_cidr' do
            it "192.168.56.100 returns 192.168.56.100" do
                assert_equal '192.168.56.100', Fog::Proxmox::IpHelper.to_cidr('192.168.56.100')
            end
            it "192.168.56.100,31 returns 192.168.56.100/31" do
                assert_equal '192.168.56.100/31', Fog::Proxmox::IpHelper.to_cidr('192.168.56.100','31')
            end
            it "192,31 returns nil" do
                assert_nil Fog::Proxmox::IpHelper.to_cidr('192','31')
            end
            it "192.168.56.100,56 returns nil" do
                assert_nil Fog::Proxmox::IpHelper.to_cidr('192.168.56.100','56')
            end
        end

        describe '#ip?' do
            it "192.168.56.100 returns true" do
                assert_equal true, Fog::Proxmox::IpHelper.ip?('192.168.56.100')
            end
            it "541536 returns false" do
                assert_equal false, Fog::Proxmox::IpHelper.ip?('541536')
            end
        end

        describe '#cidr_suffix?' do
            it "31 returns true" do
                assert_equal true, Fog::Proxmox::IpHelper.cidr_suffix?('31')
            end
            it "56 returns false" do
                assert_equal false, Fog::Proxmox::IpHelper.cidr_suffix?('56')
            end
        end
    end