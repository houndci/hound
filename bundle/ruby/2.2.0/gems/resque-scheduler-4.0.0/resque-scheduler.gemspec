# vim:fileencoding=utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque/scheduler/version'

Gem::Specification.new do |spec|
  spec.name = 'resque-scheduler'
  spec.version = Resque::Scheduler::VERSION
  spec.authors = ['Ben VandenBos']
  spec.email = ['bvandenbos@gmail.com']
  spec.homepage = 'http://github.com/resque/resque-scheduler'
  spec.summary = 'Light weight job scheduling on top of Resque'
  spec.description = <<-DESCRIPTION
    Light weight job scheduling on top of Resque.
    Adds methods enqueue_at/enqueue_in to schedule jobs in the future.
    Also supports queueing jobs on a fixed, cron-like schedule.
  DESCRIPTION
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\0")
  spec.executables = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(/^test\//)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'json'
  spec.add_development_dependency 'kramdown'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'

  # We pin rubocop because new cops have a tendency to result in false-y
  # positives for new contributors, which is not a nice experience.
  spec.add_development_dependency 'rubocop', '~> 0.28.0'

  spec.add_runtime_dependency 'mono_logger', '~> 1.0'
  spec.add_runtime_dependency 'redis', '~> 3.0'
  spec.add_runtime_dependency 'resque', '~> 1.25'
  spec.add_runtime_dependency 'rufus-scheduler', '~> 3.0'
end
