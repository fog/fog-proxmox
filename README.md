![Foreman](fogproxmox.png)

# Fog::Proxmox

[![Build Status](https://travis-ci.org/fog/fog-proxmox.svg?branch=master)](https://travis-ci.org/fog/fog-proxmox)
[![Maintainability](https://api.codeclimate.com/v1/badges/33e619f2167cc9864b61/maintainability)](https://codeclimate.com/github/fog/fog-proxmox/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/33e619f2167cc9864b61/test_coverage)](https://codeclimate.com/github/fog/fog-proxmox/test_coverage)

This is a [FOG](http://fog.io/) (>= 1.45.0) module gem to support [Proxmox VE](https://www.proxmox.com/en/proxmox-ve)

It is intended to satisfy this [feature](https://github.com/fog/fog/issues/3644), but Proxmox provider only, and above all this [Foreman](http://www.theforeman.org) [feature](https://projects.theforeman.org/issues/2186).

It is inspired by the great [fog-openstack](https://github.com/fog/fog-openstack) module.

## Compatibility versions

|Fog-Proxmox|Proxmox VE|
|--|--|
|<0.6|<5.3|
|>=0.6|>=5.3|

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fog-proxmox'
```

And then execute:

```ruby
bundle install --binstubs
```

Or install it yourself as:

```ruby
gem install fog-proxmox
```

## Usage

See [documentation](docs/getting_started.md).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

To record your VCR cassettes:

```shell
PVE_URL=https://192.168.56.101:8006/api2/json DISABLE_PROXY=true SSL_VERIFY_PEER=false bundle exec rake spec
```

To replay your recorded tests:

```shell
USE_VCR=true bundle exec rake spec
```

## Contributing

You can reach the [contributors](CONTRIBUTORS.md).
Bug reports and pull requests are welcome on GitHub at [Fog-Proxmox](https://github.com/fog/fog-proxmox/issues). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

Please read [how to contribute](CONTRIBUTING.md).

## License

The gem is available as open source under the terms of the [GPL v3 License](LICENSE).
