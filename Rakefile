#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Houndapp::Application.load_tasks
task(:default).clear

# Run webpack:build before :spec
task default: ["webpack:build", "spec", "js:spec", "bundler:audit"]

task "assets:precompile" => "webpack:build"

if defined? RSpec
  task(:spec).clear
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.verbose = false
  end
end
