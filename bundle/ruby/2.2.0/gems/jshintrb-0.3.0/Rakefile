require "bundler/gem_tasks"

[:build, :install, :release].each do |task_name|
  Rake::Task[task_name].prerequisites << :spec
end

require "multi_json"

def jshint_version
  package = File.expand_path("../vendor/jshint/package.json", __FILE__)
  MultiJson.load(File.open(package, "r:UTF-8").read)["version"]
end

task :jshint_version do
  p jshint_version
end

require 'submodule'
Submodule::Task.new do |t|
    t.test do
      sh "npm i"
      sh "npm test"
      # sh "node bin/build"
    end

    t.after_pull do
      cp "vendor/jshint/dist/jshint.js", "lib/js/jshint.js"
      sh "git add lib/js/jshint.js"
    end
end

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new

task :default => :spec

#desc "Generate code coverage"
# RSpec::Core::RakeTask.new(:coverage) do |t|
  # t.rcov = true
  # t.rcov_opts = ["--exclude", "spec"]
# end
