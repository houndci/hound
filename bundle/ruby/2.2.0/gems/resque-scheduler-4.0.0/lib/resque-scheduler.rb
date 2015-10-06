# vim:fileencoding=utf-8
require_relative 'resque/scheduler'

Resque.extend Resque::Scheduler::Extension
