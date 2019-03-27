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

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fog/proxmox/version'

Gem::Specification.new do |spec|
  spec.name          = 'fog-proxmox'
  spec.version       = Fog::Proxmox::VERSION
  spec.authors       = ['Tristan Robert']
  spec.email         = ['tristan.robert.44@gmail.com']

  spec.summary       = "Module for the 'Fog' gem to support Proxmox VE"
  spec.description   = 'This library can be used as a module for `fog`.'
  spec.homepage      = 'http://github.com/fog/fog-proxmox'
  spec.license       = 'GPL-3.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.3'
  spec.rubygems_version = '~> 2.6'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'debase', '~> 0.2.2'
  spec.add_development_dependency 'debride', '~> 1.8'
  spec.add_development_dependency 'fasterer', '~> 0.3'
  spec.add_development_dependency 'fastri', '~> 0.3'
  spec.add_development_dependency 'minitest', '~> 5.11'
  spec.add_development_dependency 'pry', '~> 0.11'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rcodetools', '~> 0.3'
  spec.add_development_dependency 'reek', '~> 4.7'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rubocop', '~> 0.55'
  spec.add_development_dependency 'ruby-debug-ide', '~> 0.6'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'vcr', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.4'

  spec.add_dependency 'fog-core',  '~> 1.45'
  spec.add_dependency 'fog-json',  '~> 1.0'
  spec.add_dependency 'ipaddress', '~> 0.8'
end
