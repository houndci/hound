# vim:fileencoding=utf-8
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'
require 'yard'

task default: [:rubocop, :test] unless RUBY_PLATFORM =~ /java/
task default: [:test] if RUBY_PLATFORM =~ /java/

RuboCop::RakeTask.new

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = ENV['PATTERN'] || 'test/*_test.rb'
  t.options = ''.tap do |o|
    o << "--seed #{ENV['SEED']} " if ENV['SEED']
    o << '--verbose ' if ENV['VERBOSE']
  end
end

YARD::Rake::YardocTask.new
