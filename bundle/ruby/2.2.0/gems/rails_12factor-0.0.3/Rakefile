#!/usr/bin/env rake
require "bundler/gem_tasks"

require "rake/testtask"
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.verbose = true
end

# In Soviet Travis CI default task runs you!
task :default => :test
