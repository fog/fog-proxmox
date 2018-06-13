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
require 'fog/proxmox/helpers/cpu_helper'

    describe Fog::Proxmox::CpuHelper do
            
        let(:cpu) do 
            'cputype=kvm64,flags=+spec-ctrl,+pcid'
        end
        let(:cpu_nocputype) do 
            'kvm64,flags=+spec-ctrl,+pcid'
        end
        let(:cpu_nospectre) do 
            'cputype=kvm64,flags=+pcid'
        end
        let(:cpu_nopcid) do 
            'cputype=kvm64,flags=+spec-ctrl'
        end

        describe '#extract' do
            it "returns array" do
                result = Fog::Proxmox::CpuHelper.extract(cpu)
                assert_equal(5, result.length)
                assert_equal('cputype=', result[0])
                assert_equal('kvm64', result[1])
                assert_equal(',flags=', result[2])
                assert_equal('+spec-ctrl', result[3])
                assert_equal('+pcid', result[4])
            end
            it "returns array" do
                result = Fog::Proxmox::CpuHelper.extract(cpu_nocputype)
                assert_equal(5, result.length)
                assert !result[0]
                assert_equal('kvm64', result[1])
                assert_equal(',flags=', result[2])
                assert_equal('+spec-ctrl', result[3])
                assert_equal('+pcid', result[4])
            end
        end

        describe '#extract_type' do
            it "returns string" do
                result = Fog::Proxmox::CpuHelper.extract_type(cpu)
                assert_equal('kvm64', result)
            end
            it "returns string" do
                result = Fog::Proxmox::CpuHelper.extract_type(cpu_nocputype)
                assert_equal('kvm64', result)
            end
        end

        describe '#extract_spectre' do
            it "returns true" do
                result = Fog::Proxmox::CpuHelper.extract_spectre(cpu)
                assert result
            end
            it "returns false" do
                result = Fog::Proxmox::CpuHelper.extract_spectre(cpu_nospectre)
                assert !result
            end
        end

        describe '#extract_pcid' do
            it "returns true" do
                result = Fog::Proxmox::CpuHelper.extract_pcid(cpu)
                assert result
            end
            it "returns false" do
                result = Fog::Proxmox::CpuHelper.extract_pcid(cpu_nopcid)
                assert !result
            end
        end
    end