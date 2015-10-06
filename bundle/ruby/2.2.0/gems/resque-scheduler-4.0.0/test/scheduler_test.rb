# vim:fileencoding=utf-8
require_relative 'test_helper'

context 'Resque::Scheduler' do
  setup do
    Resque::Scheduler.configure do |c|
      c.dynamic = false
      c.quiet = true
      c.env = nil
      c.app_name = nil
    end
    Resque.redis.flushall
    Resque::Scheduler.clear_schedule!
    Resque::Scheduler.send(:instance_variable_set, :@scheduled_jobs, {})
  end

  test 'enqueue constantizes' do
    Resque::Scheduler.env = 'production'
    config = {
      'cron' => '* * * * *',
      'class' => 'SomeRealClass',
      'args' => '/tmp'
    }
    Resque::Job.expects(:create).with(
      SomeRealClass.queue, SomeRealClass, '/tmp'
    )
    Resque::Scheduler.enqueue_from_config(config)
  end

  test 'enqueue runs hooks' do
    Resque::Scheduler.env = 'production'
    config = {
      'cron' => '* * * * *',
      'class' => 'SomeRealClass',
      'args' => '/tmp'
    }

    Resque::Job.expects(:create).with(
      SomeRealClass.queue, SomeRealClass, '/tmp'
    )
    SomeRealClass.expects(:before_delayed_enqueue_example).with('/tmp')
    SomeRealClass.expects(:before_enqueue_example).with('/tmp')
    SomeRealClass.expects(:after_enqueue_example).with('/tmp')

    Resque::Scheduler.enqueue_from_config(config)
  end

  test 'enqueue_from_config respects queue params' do
    config = {
      'cron' => '* * * * *',
      'class' => 'SomeIvarJob',
      'queue' => 'high'
    }
    Resque.expects(:enqueue_to).with('high', SomeIvarJob)
    Resque::Scheduler.enqueue_from_config(config)
  end

  test 'config makes it into the rufus_scheduler' do
    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)

    Resque.schedule = {
      some_ivar_job: {
        'cron' => '* * * * *',
        'class' => 'SomeIvarJob',
        'args' => '/tmp'
      }
    }
    Resque::Scheduler.load_schedule!

    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)
    assert Resque::Scheduler.scheduled_jobs.include?('some_ivar_job')
  end

  test 'can reload schedule' do
    Resque::Scheduler.dynamic = true
    Resque.schedule = {
      'some_ivar_job' => {
        'cron' => '* * * * *',
        'class' => 'SomeIvarJob',
        'args' => '/tmp'
      }
    }

    Resque::Scheduler.load_schedule!

    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)
    assert Resque::Scheduler.scheduled_jobs.include?('some_ivar_job')

    Resque.redis.del(:schedules)
    Resque.redis.hset(:schedules, 'some_ivar_job2', Resque.encode(
      'cron' => '* * * * *', 'class' => 'SomeIvarJob', 'args' => '/tmp/2'
    ))

    Resque::Scheduler.reload_schedule!

    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)

    assert_equal '/tmp/2', Resque.schedule['some_ivar_job2']['args']
    assert Resque::Scheduler.scheduled_jobs.include?('some_ivar_job2')
  end

  test 'load_schedule_job loads a schedule' do
    Resque::Scheduler.load_schedule_job(
      'some_ivar_job',
      'cron' => '* * * * *',
      'class' => 'SomeIvarJob',
      'args' => '/tmp'
    )

    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)
    assert_equal(1, Resque::Scheduler.scheduled_jobs.size)
    assert Resque::Scheduler.scheduled_jobs.keys.include?('some_ivar_job')
  end

  test 'load_schedule_job with every with options' do
    Resque::Scheduler.load_schedule_job(
      'some_ivar_job',
      'every' => ['30s', { 'first_in' => '60s' }],
      'class' => 'SomeIvarJob',
      'args' => '/tmp'
    )

    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)
    assert_equal(1, Resque::Scheduler.scheduled_jobs.size)
    assert Resque::Scheduler.scheduled_jobs.keys.include?('some_ivar_job')
    job = Resque::Scheduler.scheduled_jobs['some_ivar_job']
    assert job.opts.keys.include?(:first_in)
  end

  test 'load_schedule_job with cron with options' do
    Resque::Scheduler.load_schedule_job(
      'some_ivar_job',
      'cron' => ['* * * * *', { 'allow_overlapping' => 'true' }],
      'class' => 'SomeIvarJob',
      'args' => '/tmp'
    )

    assert_equal(1, Resque::Scheduler.rufus_scheduler.jobs.size)
    assert_equal(1, Resque::Scheduler.scheduled_jobs.size)
    assert Resque::Scheduler.scheduled_jobs.keys.include?('some_ivar_job')
    job = Resque::Scheduler.scheduled_jobs['some_ivar_job']
    assert job.opts.keys.include?(:allow_overlapping)
  end

  test 'load_schedule_job without cron' do
    Resque::Scheduler.load_schedule_job(
      'some_ivar_job',
      'class' => 'SomeIvarJob',
      'args' => '/tmp'
    )

    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    assert_equal(0, Resque::Scheduler.scheduled_jobs.size)
    assert !Resque::Scheduler.scheduled_jobs.keys.include?('some_ivar_job')
  end

  test 'load_schedule_job with an empty cron' do
    Resque::Scheduler.load_schedule_job(
      'some_ivar_job',
      'cron' => '',
      'class' => 'SomeIvarJob',
      'args' => '/tmp'
    )

    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    assert_equal(0, Resque::Scheduler.scheduled_jobs.size)
    assert !Resque::Scheduler.scheduled_jobs.keys.include?('some_ivar_job')
  end

  test 'update_schedule' do
    Resque::Scheduler.dynamic = true
    Resque.schedule = {
      'some_ivar_job' => {
        'cron' => '* * * * *', 'class' => 'SomeIvarJob', 'args' => '/tmp'
      },
      'another_ivar_job' => {
        'cron' => '* * * * *', 'class' => 'SomeIvarJob', 'args' => '/tmp/5'
      },
      'stay_put_job' => {
        'cron' => '* * * * *', 'class' => 'SomeJob', 'args' => '/tmp'
      }
    }

    Resque::Scheduler.load_schedule!

    Resque.set_schedule(
      'some_ivar_job',
      'cron' => '* * * * *', 'class' => 'SomeIvarJob', 'args' => '/tmp/2 '
    )
    Resque.set_schedule(
      'new_ivar_job',
      'cron' => '* * * * *', 'class' => 'SomeJob', 'args' => '/tmp/3 '
    )
    Resque.set_schedule(
      'stay_put_job',
      'cron' => '* * * * *', 'class' => 'SomeJob', 'args' => '/tmp '
    )
    Resque.remove_schedule('another_ivar_job')

    Resque::Scheduler.update_schedule

    assert_equal(3, Resque::Scheduler.rufus_scheduler.jobs.size)
    assert_equal(3, Resque::Scheduler.scheduled_jobs.size)
    %w(some_ivar_job new_ivar_job stay_put_job).each do |job_name|
      assert Resque::Scheduler.scheduled_jobs.keys.include?(job_name)
      assert Resque.schedule.keys.include?(job_name)
    end
    assert !Resque::Scheduler.scheduled_jobs.keys.include?('another_ivar_job')
    assert !Resque.schedule.keys.include?('another_ivar_job')
    assert_equal 0, Resque.redis.scard(:schedules_changed)
  end

  test 'update_schedule when all jobs have been removed' do
    Resque::Scheduler.dynamic = true
    Resque.schedule = {
      'some_ivar_job' => {
        'cron' => '* * * * *', 'class' => 'SomeIvarJob', 'args' => '/tmp'
      }
    }

    Resque::Scheduler.load_schedule!

    Resque.remove_schedule('some_ivar_job')

    Resque::Scheduler.update_schedule

    assert_equal(0, Resque::Scheduler.rufus_scheduler.jobs.size)
    assert_equal(0, Resque::Scheduler.scheduled_jobs.size)
    assert_equal([], Resque::Scheduler.scheduled_jobs.keys)
    assert_equal 0, Resque.redis.scard(:schedules_changed)
  end

  test 'update_schedule with mocks' do
    Resque::Scheduler.dynamic = true
    Resque.schedule = {
      'some_ivar_job' => {
        'cron' => '* * * * *', 'class' => 'SomeIvarJob', 'args' => '/tmp'
      },
      'another_ivar_job' => {
        'cron' => '* * * * *', 'class' => 'SomeIvarJob', 'args' => '/tmp/5'
      },
      'stay_put_job' => {
        'cron' => '* * * * *', 'class' => 'SomeJob', 'args' => '/tmp'
      }
    }

    Resque::Scheduler.load_schedule!

    Resque.set_schedule(
      'some_ivar_job',
      'cron' => '* * * * *', 'class' => 'SomeIvarJob', 'args' => '/tmp/2 '
    )
    Resque.set_schedule(
      'new_ivar_job',
      'cron' => '* * * * *', 'class' => 'SomeJob', 'args' => '/tmp/3 '
    )
    Resque.set_schedule(
      'stay_put_job',
      'cron' => '* * * * *', 'class' => 'SomeJob', 'args' => '/tmp '
    )
    Resque.remove_schedule('another_ivar_job')

    Resque::Scheduler.update_schedule

    assert_equal(3, Resque::Scheduler.scheduled_jobs.size)
    %w(some_ivar_job new_ivar_job stay_put_job).each do |job_name|
      assert Resque::Scheduler.scheduled_jobs.keys.include?(job_name)
      assert Resque.schedule.keys.include?(job_name)
    end
    assert !Resque::Scheduler.scheduled_jobs.keys.include?('another_ivar_job')
    assert !Resque.schedule.keys.include?('another_ivar_job')
    assert_equal 0, Resque.redis.scard(:schedules_changed)
  end

  test 'concurrent update_schedule calls' do
    Resque::Scheduler.dynamic = true
    Resque::Scheduler.load_schedule!
    jobs_count = 100

    background_delayed_update = Thread.new do
      sleep(0.01)
      Resque::Scheduler.update_schedule
    end

    (0...jobs_count).each do |i|
      Resque.set_schedule(
        "some_ivar_job#{i}",
        'cron' => '* * * * *', 'class' => 'SomeIvarJob', 'args' => "/tmp/#{i}"
      )
    end

    background_delayed_update.join
    Resque::Scheduler.update_schedule
    assert_equal(jobs_count, Resque::Scheduler.rufus_scheduler.jobs.size)
    assert_equal(jobs_count, Resque::Scheduler.scheduled_jobs.size)
    assert_equal 0, Resque.redis.scard(:schedules_changed)
  end

  test 'schedule= sets the schedule' do
    Resque::Scheduler.dynamic = true
    Resque.schedule = {
      'my_ivar_job' => {
        'cron' => '* * * * *',
        'class' => 'SomeIvarJob',
        'args' => '/tmp/75'
      }
    }
    assert_equal(
      { 'cron' => '* * * * *', 'class' => 'SomeIvarJob', 'args' => '/tmp/75' },
      Resque.decode(Resque.redis.hget(:schedules, 'my_ivar_job'))
    )
  end

  test 'schedule= removes schedules not present in the given ' \
       'schedule argument' do
    Resque::Scheduler.dynamic = true

    Resque.schedule = {
      'old_job' => { 'cron' => '* * * * *', 'class' => 'OldJob' }
    }
    assert_equal(
      { 'old_job' => { 'cron' => '* * * * *', 'class' => 'OldJob' } },
      Resque.schedule
    )

    Resque.schedule = {
      'new_job' => { 'cron' => '* * * * *', 'class' => 'NewJob' }
    }
    Resque.reload_schedule!
    assert_equal(
      { 'new_job' => { 'cron' => '* * * * *', 'class' => 'NewJob' } },
      Resque.schedule
    )
  end

  test "schedule= uses job name as 'class' argument if it's missing" do
    Resque::Scheduler.dynamic = true
    Resque.schedule = { 'SomeIvarJob' => {
      'cron' => '* * * * *', 'args' => '/tmp/75'
    } }
    assert_equal(
      { 'cron' => '* * * * *', 'class' => 'SomeIvarJob', 'args' => '/tmp/75' },
      Resque.decode(Resque.redis.hget(:schedules, 'SomeIvarJob'))
    )
    assert_equal('SomeIvarJob', Resque.schedule['SomeIvarJob']['class'])
  end

  test 'schedule= does not mutate argument' do
    schedule = { 'SomeIvarJob' => {
      'cron' => '* * * * *', 'args' => '/tmp/75'
    } }
    Resque.schedule = schedule
    assert !schedule['SomeIvarJob'].key?('class')
  end

  test 'set_schedule can set an individual schedule' do
    Resque.set_schedule(
      'some_ivar_job',
      'cron' => '* * * * *', 'class' => 'SomeIvarJob', 'args' => '/tmp/22'
    )
    assert_equal(
      { 'cron' => '* * * * *', 'class' => 'SomeIvarJob', 'args' => '/tmp/22' },
      Resque.decode(Resque.redis.hget(:schedules, 'some_ivar_job'))
    )
    assert Resque.redis.sismember(:schedules_changed, 'some_ivar_job')
  end

  test 'fetch_schedule returns a schedule' do
    Resque.redis.hset(:schedules, 'some_ivar_job2', Resque.encode(
      'cron' => '* * * * *', 'class' => 'SomeIvarJob', 'args' => '/tmp/33'
    ))
    assert_equal(
      { 'cron' => '* * * * *', 'class' => 'SomeIvarJob', 'args' => '/tmp/33' },
      Resque.fetch_schedule('some_ivar_job2')
    )
  end

  test 'remove_schedule removes a schedule' do
    Resque.set_schedule(
      'some_ivar_job3',
      'cron' => '* * * * *',
      'class' => 'SomeIvarJob',
      'args' => '/tmp/44',
      'persist' => true
    )
    Resque::Scheduler.load_schedule!
    Resque.remove_schedule('some_ivar_job3')
    assert_equal nil, Resque.redis.hget(:schedules, 'some_ivar_job3')
    assert Resque.redis.sismember(:schedules_changed, 'some_ivar_job3')
    assert_equal [], Resque.redis.smembers(:persisted_schedules)
  end

  test 'persisted schedules' do
    Resque.set_schedule(
      'some_ivar_job',
      'cron' => '* * * * *',
      'class' => 'SomeIvarJob',
      'args' => '/tmp/2',
      'persist' => true
    )
    Resque.set_schedule(
      'new_ivar_job',
      'cron' => '* * * * *',
      'class' => 'SomeJob',
      'args' => '/tmp/3 '
    )

    Resque.schedule = {
      'a_schedule' => {
        'cron' => '* * * * *', 'class' => 'SomeOtherJob', 'args' => '/tmp'
      }
    }
    Resque::Scheduler.load_schedule!

    assert_equal(
      { 'cron' => '* * * * *', 'class' => 'SomeIvarJob', 'args' => '/tmp/2' },
      Resque.schedule['some_ivar_job']
    )
    assert_equal(nil, Resque.schedule['some_job'])
  end

  test 'adheres to lint' do
    assert_nothing_raised do
      Resque::Plugin.lint(Resque::Scheduler)
      Resque::Plugin.lint(Resque::Scheduler::Extension)
    end
  end

  test 'procline contains app_name when present' do
    Resque::Scheduler.app_name = 'foo'
    assert Resque::Scheduler.send(:build_procline, 'bar') =~ /\[foo\]:/
  end

  test 'procline omits app_name when absent' do
    Resque::Scheduler.app_name = nil
    assert Resque::Scheduler.send(:build_procline, 'bar') =~
      /#{Resque::Scheduler.send(:internal_name)}: bar/
  end

  test 'procline contains env when present' do
    Resque::Scheduler.env = 'xyz'
    assert Resque::Scheduler.send(:build_procline, 'cage') =~ /\[xyz\]: cage/
  end

  test 'procline omits env when absent' do
    Resque::Scheduler.env = nil
    assert Resque::Scheduler.send(:build_procline, 'cage') =~
      /#{Resque::Scheduler.send(:internal_name)}: cage/
  end

  context 'printing schedule' do
    setup do
      Resque::Scheduler.expects(:log!).at_least_once
    end

    test 'prints schedule' do
      fake_rufus_scheduler = mock
      fake_rufus_scheduler.expects(:jobs).at_least_once
        .returns(foo: OpenStruct.new(t: nil, last: nil))
      Resque::Scheduler.expects(:rufus_scheduler).at_least_once
        .returns(fake_rufus_scheduler)
      Resque::Scheduler.print_schedule
    end
  end
end
