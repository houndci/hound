# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "simple-random"
  gem.homepage = "http://github.com/ealdent/simple-random"
  gem.licenses = "CDDL-1.0"
  gem.summary = %Q{Simple Random Number Generator}
  gem.description = %Q{Simple Random Number Generator including Beta, Cauchy, Chi square, Exponential, Gamma, Inverse Gamma, Laplace (double exponential), Normal, Student t, Uniform, and Weibull.  Ported from John D. Cook's C# Code.}
  gem.email = "jasonmadams@gmail.com"
  gem.authors = ["John D. Cook", "Jason Adams"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['test'].execute
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "simple-random #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
