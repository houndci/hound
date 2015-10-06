# vim:fileencoding=utf-8

require_relative 'test_helper'

context 'scheduling jobs with arguments' do
  setup do
    Resque::Scheduler.clear_schedule!
    Resque::Scheduler.configure do |c|
      c.dynamic = false
      c.quiet = true
      c.poll_sleep_amount = nil
    end
  end

  test 'enqueue_from_config puts stuff in resque without class loaded' do
    Resque::Job.stubs(:create).once.returns(true)
      .with('joes_queue', 'UndefinedJob', '/tmp')
    Resque::Scheduler.enqueue_from_config(
      'cron' => '* * * * *',
      'class' => 'UndefinedJob',
      'args' => '/tmp',
      'queue' => 'joes_queue'
    )
  end

  test 'enqueue_from_config with_every_syntax' do
    Resque::Job.stubs(:create).once.returns(true)
      .with('james_queue', 'JamesJob', '/tmp')
    Resque::Scheduler.enqueue_from_config(
      'every' => '1m',
      'class' => 'JamesJob',
      'args' => '/tmp',
      'queue' => 'james_queue'
    )
  end

  test 'enqueue_from_config puts jobs in the resque queue' do
    Resque::Job.stubs(:create).once.returns(true)
      .with(:ivar, SomeIvarJob, '/tmp')
    Resque::Scheduler.enqueue_from_config(
      'cron' => '* * * * *',
      'class' => 'SomeIvarJob',
      'args' => '/tmp'
    )
  end

  test 'enqueue_from_config with custom_class_job in resque' do
    FakeCustomJobClass.stubs(:scheduled).once.returns(true)
      .with(:ivar, 'SomeIvarJob', '/tmp')
    Resque::Scheduler.enqueue_from_config(
      'cron' => '* * * * *',
      'class' => 'SomeIvarJob',
      'custom_job_class' => 'FakeCustomJobClass',
      'args' => '/tmp'
    )
  end

  test 'enqueue_from_config puts stuff in resque when env matches' do
    Resque::Scheduler.env = 'production'
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)

    Resque.schedule = {
      'some_ivar_job' => {
        'cron' => '* * * * *',
        'class' => 'SomeIvarJob',
        'args' => '/tmp',
        'rails_env' => 'production'
      }
    }

    Resque::Scheduler.load_schedule!
    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)

    Resque.schedule = {
      'some_ivar_job' => {
        'cron' => '* * * * *',
        'class' => 'SomeIvarJob',
        'args' => '/tmp',
        'env' => 'staging, production'
      }
    }

    Resque::Scheduler.load_schedule!
    assert_equal(2, Resque::Scheduler.rufus_scheduler.jobs.size)
  end

  test 'enqueue_from_config does not enqueue when env does not match' do
    Resque::Scheduler.env = nil
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    Resque.schedule = {
      'some_ivar_job' => {
        'cron' => '* * * * *',
        'class' => 'SomeIvarJob',
        'args' => '/tmp',
        'rails_env' => 'staging'
      }
    }

    Resque::Scheduler.load_schedule!
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)

    Resque::Scheduler.env = 'production'
    Resque.schedule = {
      'some_ivar_job' => {
        'cron' => '* * * * *',
        'class' => 'SomeIvarJob',
        'args' => '/tmp',
        'env' => 'staging'
      }
    }
    Resque::Scheduler.load_schedule!
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
  end

  test 'enqueue_from_config when env env arg is not set' do
    Resque::Scheduler.env = 'production'
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)

    Resque.schedule = {
      'some_ivar_job' => {
        'cron' => '* * * * *',
        'class' => 'SomeIvarJob',
        'args' => '/tmp'
      }
    }
    Resque::Scheduler.load_schedule!
    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)
  end

  test "calls the worker without arguments when 'args' is missing " \
       'from the config' do
    Resque::Scheduler.enqueue_from_config(YAML.load(<<-YAML))
      class: SomeIvarJob
    YAML
    SomeIvarJob.expects(:perform).once.with
    Resque.reserve('ivar').perform
  end

  test "calls the worker without arguments when 'args' is blank " \
       'in the config' do
    Resque::Scheduler.enqueue_from_config(YAML.load(<<-YAML))
      class: SomeIvarJob
      args:
    YAML
    SomeIvarJob.expects(:perform).once.with
    Resque.reserve('ivar').perform
  end

  test 'calls the worker with a string when the config lists a string' do
    Resque::Scheduler.enqueue_from_config(YAML.load(<<-YAML))
      class: SomeIvarJob
      args: string
    YAML
    SomeIvarJob.expects(:perform).once.with('string')
    Resque.reserve('ivar').perform
  end

  test 'calls the worker with a Fixnum when the config lists an integer' do
    Resque::Scheduler.enqueue_from_config(YAML.load(<<-YAML))
      class: SomeIvarJob
      args: 1
    YAML
    SomeIvarJob.expects(:perform).once.with(1)
    Resque.reserve('ivar').perform
  end

  test 'calls the worker with multiple arguments when the config ' \
       'lists an array' do
    Resque::Scheduler.enqueue_from_config(YAML.load(<<-YAML))
      class: SomeIvarJob
      args:
        - 1
        - 2
    YAML
    SomeIvarJob.expects(:perform).once.with(1, 2)
    Resque.reserve('ivar').perform
  end

  test 'calls the worker with an array when the config lists ' \
       'a nested array' do
    Resque::Scheduler.enqueue_from_config(YAML.load(<<-YAML))
      class: SomeIvarJob
      args:
        - - 1
          - 2
    YAML
    SomeIvarJob.expects(:perform).once.with([1, 2])
    Resque.reserve('ivar').perform
  end

  test 'calls the worker with a hash when the config lists a hash' do
    Resque::Scheduler.enqueue_from_config(YAML.load(<<-YAML))
      class: SomeIvarJob
      args:
        key: value
    YAML
    SomeIvarJob.expects(:perform).once.with('key' => 'value')
    Resque.reserve('ivar').perform
  end

  test 'calls the worker with a nested hash when the config lists ' \
       'a nested hash' do
    Resque::Scheduler.enqueue_from_config(YAML.load(<<-YAML))
      class: SomeIvarJob
      args:
        first_key:
          second_key: value
    YAML
    SomeIvarJob.expects(:perform).once
      .with('first_key' => { 'second_key' => 'value' })
    Resque.reserve('ivar').perform
  end

  test 'poll_sleep_amount defaults to 5' do
    assert_equal 5, Resque::Scheduler.poll_sleep_amount
  end

  test 'poll_sleep_amount is settable' do
    Resque::Scheduler.poll_sleep_amount = 1
    assert_equal 1, Resque::Scheduler.poll_sleep_amount
  end
end
