# vim:fileencoding=utf-8
require_relative 'test_helper'

context 'Resque::Scheduler' do
  setup do
    ENV['VERBOSE'] = nil
    nullify_logger
    Resque::Scheduler.dynamic = false
    Resque.redis.flushall
    Resque::Scheduler.clear_schedule!
  end

  teardown { restore_devnull_logfile }

  test 'set custom logger' do
    custom_logger = MonoLogger.new('/dev/null')
    Resque::Scheduler.send(:logger=, custom_logger)
    assert_equal(custom_logger, Resque::Scheduler.send(:logger))
  end

  test 'configure block' do
    Resque::Scheduler.quiet = false
    Resque::Scheduler.configure do |c|
      c.quiet = true
    end
    assert_equal(Resque::Scheduler.quiet, true)
  end

  context 'when getting the env' do
    def wipe
      Resque::Scheduler.env = nil
      Rails.env = nil
      ENV['RAILS_ENV'] = nil
    end

    setup { wipe }
    teardown { wipe }

    test 'uses the value if set' do
      Resque::Scheduler.env = 'foo'
      assert_equal('foo', Resque::Scheduler.env)
    end

    test 'uses Rails.env if present' do
      Rails.env = 'bar'
      assert_equal('bar', Resque::Scheduler.env)
    end

    test 'uses $RAILS_ENV if present' do
      ENV['RAILS_ENV'] = 'baz'
      assert_equal('baz', Resque::Scheduler.env)
    end
  end

  context 'logger default settings' do
    setup { nullify_logger }
    teardown { restore_devnull_logfile }

    test 'uses STDOUT' do
      assert_equal(
        Resque::Scheduler.send(:logger)
          .instance_variable_get(:@logdev).dev, $stdout
      )
    end

    test 'not verbose' do
      assert Resque::Scheduler.send(:logger).level > MonoLogger::DEBUG
    end

    test 'not quieted' do
      assert Resque::Scheduler.send(:logger).level < MonoLogger::FATAL
    end
  end

  context 'logger custom settings' do
    setup { nullify_logger }
    teardown { restore_devnull_logfile }

    test 'uses logfile' do
      Resque::Scheduler.logfile = '/dev/null'
      assert_equal(
        Resque::Scheduler.send(:logger)
          .instance_variable_get(:@logdev).filename,
        '/dev/null'
      )
    end

    test 'set verbosity' do
      Resque::Scheduler.verbose = true
      assert Resque::Scheduler.send(:logger).level == MonoLogger::DEBUG
    end

    test 'quiet logger' do
      Resque::Scheduler.quiet = true
      assert Resque::Scheduler.send(:logger).level == MonoLogger::FATAL
    end
  end

  context 'logger with json formatter' do
    setup do
      nullify_logger
      Resque::Scheduler.logformat = 'json'
      $stdout = StringIO.new
    end

    teardown do
      $stdout = STDOUT
    end

    test 'logs with json' do
      Resque::Scheduler.log! 'whatever'
      assert $stdout.string =~ /"msg":"whatever"/
    end
  end

  context 'logger with text formatter' do
    setup do
      nullify_logger
      Resque::Scheduler.logformat = 'text'
      $stdout = StringIO.new
    end

    teardown do
      $stdout = STDOUT
    end

    test 'logs with text' do
      Resque::Scheduler.log! 'another thing'
      assert $stdout.string =~ /: another thing/
    end
  end
end
