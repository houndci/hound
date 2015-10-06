# vim:fileencoding=utf-8
require 'simplecov'

require 'test/unit'
require 'mocha/setup'
require 'rack/test'
require 'resque'

$LOAD_PATH.unshift File.dirname(File.expand_path(__FILE__)) + '/../lib'
require 'resque-scheduler'
require 'resque/scheduler/server'

unless ENV['RESQUE_SCHEDULER_DISABLE_TEST_REDIS_SERVER']
  # Start our own Redis when the tests start. RedisInstance will take care of
  # starting and stopping.
  require File.expand_path('../support/redis_instance', __FILE__)
  RedisInstance.run!
end

at_exit { exit MiniTest::Unit.new.run(ARGV) || 0 }

##
# test/spec/mini 3
# original work: http://gist.github.com/25455
# forked and modified: https://gist.github.com/meatballhat/8906709
#
def context(*args, &block)
  return super unless (name = args.first) && block
  require 'test/unit'
  klass = Class.new(Test::Unit::TestCase) do
    def self.test(name, &block)
      define_method("test_#{name.gsub(/\W/, '_')}", &block) if block
    end
    def self.xtest(*_args)
    end
    def self.setup(&block)
      define_method(:setup, &block)
    end
    def self.teardown(&block)
      define_method(:teardown, &block)
    end
  end
  (class << klass; self end).send(:define_method, :name) do
    name.gsub(/\W/, '_')
  end
  klass.class_eval(&block)
end

unless defined?(Rails)
  module Rails
    class << self
      attr_accessor :env
    end
  end
end

class FakeCustomJobClass
  def self.scheduled(_queue, _klass, *_args); end
end

class FakeCustomJobClassEnqueueAt
  @queue = :test
  def self.scheduled(_queue, _klass, *_args); end
end

class SomeJob
  def self.perform(_repo_id, _path)
  end
end

class SomeIvarJob < SomeJob
  @queue = :ivar
end

class SomeFancyJob < SomeJob
  def self.queue
    :fancy
  end
end

class SomeSharedEnvJob < SomeJob
  def self.queue
    :shared_job
  end
end

class SomeQuickJob < SomeJob
  @queue = :quick
end

class SomeRealClass
  def self.queue
    :some_real_queue
  end
end

class JobWithParams
  def self.perform(*args)
    @args = args
  end
end

JobWithoutParams = Class.new(JobWithParams)

%w(
  APP_NAME
  DYNAMIC_SCHEDULE
  LOGFILE
  LOGFORMAT
  QUIET
  RAILS_ENV
  RESQUE_SCHEDULER_INTERVAL
  VERBOSE
).each do |envvar|
  ENV[envvar] = nil
end

def nullify_logger
  Resque::Scheduler.configure do |c|
    c.quiet = nil
    c.verbose = nil
    c.logfile = nil
    c.send(:logger=, nil)
  end

  ENV['LOGFILE'] = nil
end

def restore_devnull_logfile
  nullify_logger
  ENV['LOGFILE'] = '/dev/null'
end

restore_devnull_logfile
