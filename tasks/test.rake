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

namespace :spec do
    desc 'Run fog-proxmox spec/*'
    Rake::TestTask.new do |t|
      t.name = 'all'
      t.description = 'Run all specs'
      t.libs.push %w[lib spec]
      t.pattern = 'spec/**/*_spec.rb'
      t.verbose = true
    end
  
    desc 'Run fog-proxmox spec/helpers/*'
    Rake::TestTask.new do |t|
      t.name = 'helpers'
      t.description = 'Run helpers tests'
      t.libs.push %w[lib spec]
      t.pattern = 'spec/helpers/**/*_spec.rb'
      t.verbose = true
    end
  
    desc 'Run fog-proxmox spec/compute'
    Rake::TestTask.new do |t|
      t.name = 'compute'
      t.description = 'Run compute API tests'
      t.libs.push %w[lib spec]
      t.pattern = 'spec/**/compute_spec.rb'
      t.verbose = true
    end
  
    desc 'Run fog-proxmox spec/identity'
    Rake::TestTask.new do |t|
      t.name = 'identity'
      t.description = 'Run identity API tests'
      t.libs.push %w[lib spec]
      t.pattern = 'spec/**/identity_spec.rb'
      t.verbose = true
    end
  
    desc 'Run fog-proxmox spec/network'
    Rake::TestTask.new do |t|
      t.name = 'network'
      t.description = 'Run network API tests'
      t.libs.push %w[lib spec]
      t.pattern = 'spec/**/network_spec.rb'
      t.verbose = true
    end
  end
  