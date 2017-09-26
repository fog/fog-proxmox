# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fog/proxmox/version'

Gem::Specification.new do |spec|
  spec.name          = 'fog-proxmox'
  spec.version       = Fog::Proxmox::VERSION
  spec.authors       = ['Tristan Robert']
  spec.email         = ['tristan.robert.44@gmail.com']

  spec.summary       = "Module for the 'Fog' gem to support Proxmox VE"
  spec.description   = 'This library can be used as a module for `fog`.'
  spec.homepage      = 'http://github.com/tristanrobert/fog-proxmox'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '~> 2.4'
  spec.rubygems_version = '~> 2.6'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'ruby-debug-ide', '~> 0.6'
  spec.add_development_dependency 'rubocop', '~> 0.50'
  spec.add_development_dependency 'pry', '~> 0.11'
  spec.add_development_dependency 'debase', '~> 0.2'
  spec.add_development_dependency 'reek', '~> 4.7'
  spec.add_development_dependency 'debride', '~> 1.8'
  spec.add_development_dependency 'fasterer', '~> 0.3'
  spec.add_development_dependency 'fastri', '~> 0.3'
  spec.add_development_dependency 'rcodetools', '~> 0.3'

  spec.add_dependency 'fog-core',  '~> 1.45'
  spec.add_dependency 'fog-json',  '~> 1.0'
  spec.add_dependency 'ipaddress', '~> 0.8'
end
