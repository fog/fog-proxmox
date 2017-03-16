# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fog/proxmox/version'

Gem::Specification.new do |spec|
  spec.name          = "fog-proxmox"
  spec.version       = Fog::Proxmox::VERSION
  spec.authors       = ["Tristan Robert"]
  spec.email         = ["tristan.robert.44@gmail.com"]

  spec.summary       = %q{Module for the 'Fog' gem to support Proxmox VE}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "This library can be used as a module for `fog`."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    =  spec.files.grep(%r{^(test|spec|features)/})
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency 'fog-core',  '~> 1.38'
  spec.add_dependency 'fog-json',  '~> 1.0'
  spec.add_dependency 'fog-xml',   '~> 0.1'
  spec.add_dependency 'ipaddress', '~> 0.8'

end
