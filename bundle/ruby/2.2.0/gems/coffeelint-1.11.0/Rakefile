require "bundler/gem_tasks"
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new('spec')

task :default => :spec

task :console do
  sh "irb -rubygems -I lib -r coffeelint.rb"
end

task :cmd do
  sh "ruby -I lib -- bin/coffeelint.rb"
end

task :prepare_coffeelint do
  sh "git submodule init"
  sh "git submodule update"

  Dir.chdir('coffeelint') do
    sh "npm install"
    sh "npm run compile"
  end
end

task :compile => [:prepare, :build]

task :prepare do
  sh "git submodule init"
  sh "git submodule update"

  Dir.chdir('coffeelint') do
    sh "npm install"
    sh "npm run compile"
  end

  sh "rake spec"
end

def coffeelint_version
  Dir.chdir('coffeelint') do
    retval = `git describe`
    retval.strip! || retval
  end
end

task :update_readme do
  readme_name = 'README.md'
  readme = File.read(readme_name)
  readme = readme.gsub(/(coffeelint version: )v[0-9.]+/, "\\1#{coffeelint_version}")
  File.open(readme_name, 'w') do |f|
    f.write(readme)
  end
end
