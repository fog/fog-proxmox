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

require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rake/testtask'

RuboCop::RakeTask.new

task default: :test

desc 'Run fog-proxmox unit tests with Minitest'
task :test do
  mock = ENV['FOG_MOCK'] || 'true'
  sh("export FOG_MOCK=#{mock} && bundle exec rake tests:unit")
end

desc 'Run fog-proxmox spec/ tests (VCR)'
task spec: 'tests:spec'

namespace :tests do
  desc 'Run fog-proxmox test/'
  Rake::TestTask.new do |t|
    t.name = 'unit'
    t.libs.push %w[lib test]
    t.test_files = FileList['test/**/*.rb']
    t.verbose = true
  end

  desc 'Run fog-proxmox spec/'
  Rake::TestTask.new do |t|
    t.name = 'spec'
    t.libs.push %w[lib spec]
    t.pattern = 'spec/**/*_spec.rb'
    t.verbose = true
  end
end
