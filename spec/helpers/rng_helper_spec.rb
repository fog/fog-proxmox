# frozen_string_literal: true

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
require 'fog/proxmox/helpers/rng_helper'

rng_helper_class = Fog::Proxmox::RngHelper

describe Fog::Proxmox::RngHelper do
  let(:rng_value) { 'max_bytes=1024,period=2000,source=/dev/urandom' }
  let(:rng_attributes) { { max_bytes: '1024', period: '2000', source: '/dev/urandom' } }

  it 'extracts all RNG options' do
    assert_equal rng_attributes, rng_helper_class.extract(rng_value)
  end

  it 'extracts options regardless of their order' do
    assert_equal rng_attributes,
                 rng_helper_class.extract('source=/dev/urandom,period=2000,max_bytes=1024')
  end

  it 'extracts a quoted period without the surrounding quotes' do
    assert_equal rng_attributes,
                 rng_helper_class.extract('source=/dev/urandom,max_bytes=1024,period="2000"')
  end

  it 'extracts quoted values for all RNG options' do
    assert_equal rng_attributes,
                 rng_helper_class.extract('max_bytes="1024",period="2000",source="/dev/urandom"')
  end

  it 'extracts a source without optional rate limits' do
    assert_equal({ source: '/dev/hwrng' },
                 rng_helper_class.extract('source=/dev/hwrng'))
  end

  it 'ignores unsupported options when extracting' do
    assert_equal({ source: '/dev/urandom' },
                 rng_helper_class.extract('source=/dev/urandom,unknown=value'))
  end

  it 'flattens all RNG options' do
    assert_equal({ rng0: rng_value }, rng_helper_class.flatten(rng_attributes))
  end

  it 'accepts each supported RNG source' do
    %w[/dev/urandom /dev/random /dev/hwrng].each do |source|
      assert_equal({ rng0: "source=#{source}" }, rng_helper_class.flatten(source: source))
    end
  end

  it 'requires a source when configuring an RNG device' do
    [{}, { max_bytes: 1024 }, { source: nil }, { source: '' }].each do |attributes|
      error = assert_raises(ArgumentError) { rng_helper_class.flatten(attributes) }
      assert_match(/RNG source is required/, error.message)
    end
  end

  it 'rejects unsupported or partially matching source paths' do
    ['/dev/null', '/dev/random/extra', 'prefix/dev/urandom', "/dev/hwrng\n", ' '].each do |source|
      assert_raises(ArgumentError) { rng_helper_class.flatten(source: source) }
    end
  end

  it 'accepts integer rate limits' do
    assert_equal({ rng0: rng_value },
                 rng_helper_class.flatten(max_bytes: 1024, period: 2000, source: '/dev/urandom'))
  end

  %i[max_bytes period].each do |key|
    it "rejects invalid #{key} values" do
      ['abc', '1024bytes', '1.5', 1.5, -1, '-1', true, ' ', "1024\n"].each do |value|
        error = assert_raises(ArgumentError) do
          rng_helper_class.flatten(source: '/dev/urandom', key => value)
        end
        assert_equal "RNG #{key} must be a non-negative integer", error.message
      end
    end
  end

  it 'omits unset options and retains zero values' do
    assert_equal({ rng0: 'max_bytes=0,source=/dev/random' },
                 rng_helper_class.flatten(max_bytes: 0, period: nil, source: '/dev/random'))
  end

  it 'omits blank limits and unsupported options' do
    assert_equal({ rng0: 'source=/dev/urandom' },
                 rng_helper_class.flatten(max_bytes: '', period: '', source: '/dev/urandom', unknown: 'value'))
  end

  it 'returns an empty hash for a missing device' do
    assert_empty rng_helper_class.flatten(nil)
  end
end
