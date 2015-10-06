# vim:fileencoding=utf-8
require_relative 'test_helper'

module LockTestHelper
  def lock_is_not_held(lock)
    Resque.redis.set(lock.key, 'anothermachine:1234')
  end
end

context '#master_lock_key' do
  setup do
    @subject = Class.new { extend Resque::Scheduler::Locking }
  end

  teardown do
    Resque.redis.del(@subject.master_lock.key)
  end

  test 'should have resque prefix' do
    assert_equal(
      @subject.master_lock.key, 'resque:resque_scheduler_master_lock'
    )
  end

  context 'with a prefix set via ENV' do
    setup do
      ENV['RESQUE_SCHEDULER_MASTER_LOCK_PREFIX'] = 'my.prefix'
      @subject = Class.new { extend Resque::Scheduler::Locking }
    end

    teardown do
      Resque.redis.del(@subject.master_lock.key)
    end

    test 'should have ENV prefix' do
      assert_equal(
        @subject.master_lock.key,
        'resque:my.prefix:resque_scheduler_master_lock'
      )
    end
  end

  context 'with a namespace set for resque' do
    setup do
      Resque.redis.namespace = 'my.namespace'
      @subject = Class.new { extend Resque::Scheduler::Locking }
    end

    teardown do
      Resque.redis.namespace = 'resque'
      Resque.redis.del(@subject.master_lock.key)
    end

    test 'should have resque prefix' do
      assert_equal(
        @subject.master_lock.key, 'my.namespace:resque_scheduler_master_lock'
      )
    end

    context 'with a prefix set via ENV' do
      setup do
        Resque.redis.namespace = 'my.namespace'
        ENV['RESQUE_SCHEDULER_MASTER_LOCK_PREFIX'] = 'my.prefix'
        @subject = Class.new { extend Resque::Scheduler::Locking }
      end

      teardown do
        Resque.redis.namespace = 'resque'
        Resque.redis.del(@subject.master_lock.key)
      end

      test 'should have ENV prefix' do
        assert_equal(
          @subject.master_lock.key,
          'my.namespace:my.prefix:resque_scheduler_master_lock'
        )
      end
    end
  end
end

context 'Resque::Scheduler::Locking' do
  setup do
    @subject = Class.new { extend Resque::Scheduler::Locking }
  end

  teardown do
    Resque.redis.del(@subject.master_lock.key)
  end

  test 'should use the basic lock mechanism for <= Redis 2.4' do
    Resque.redis.stubs(:info).returns('redis_version' => '2.4.16')

    assert_equal @subject.master_lock.class, Resque::Scheduler::Lock::Basic
  end

  test 'should use the resilient lock mechanism for > Redis 2.4' do
    Resque.redis.stubs(:info).returns('redis_version' => '2.5.12')

    assert_equal(
      @subject.master_lock.class, Resque::Scheduler::Lock::Resilient
    )
  end

  test 'should be the master if the lock is held' do
    @subject.master_lock.acquire!
    assert @subject.master?, 'should be master'
  end

  test 'should not be the master if the lock is held by someone else' do
    Resque.redis.set(@subject.master_lock.key, 'somethingelse:1234')
    assert !@subject.master?, 'should not be master'
  end

  test 'release_master_lock should delegate to master_lock' do
    @subject.master_lock.expects(:release)
    @subject.release_master_lock
  end

  test 'release_master_lock! should delegate to master_lock' do
    @subject.expects(:warn)
    @subject.master_lock.expects(:release!)
    @subject.release_master_lock!
  end
end

context 'Resque::Scheduler::Lock::Base' do
  setup do
    @lock = Resque::Scheduler::Lock::Base.new('test_lock_key')
  end

  test '#acquire! should be not implemented' do
    assert_raises NotImplementedError do
      @lock.acquire!
    end
  end

  test '#locked? should be not implemented' do
    assert_raises NotImplementedError do
      @lock.locked?
    end
  end
end

context 'Resque::Scheduler::Lock::Basic' do
  include LockTestHelper

  setup do
    @lock = Resque::Scheduler::Lock::Basic.new('test_lock_key')
  end

  teardown do
    @lock.release!
  end

  test 'you should not have the lock if someone else holds it' do
    lock_is_not_held(@lock)

    assert !@lock.locked?
  end

  test 'you should not be able to acquire the lock if someone ' \
       'else holds it' do
    lock_is_not_held(@lock)

    assert !@lock.acquire!
  end

  test 'the lock should receive a TTL on acquiring' do
    @lock.acquire!

    assert Resque.redis.ttl(@lock.key) > 0, 'lock should expire'
  end

  test 'releasing should release the master lock' do
    assert @lock.acquire!, 'should have acquired the master lock'
    assert @lock.locked?, 'should be locked'

    @lock.release!

    assert !@lock.locked?, 'should not be locked'
  end

  test 'checking the lock should increase the TTL if we hold it' do
    @lock.acquire!
    Resque.redis.setex(@lock.key, 10, @lock.value)

    @lock.locked?

    assert Resque.redis.ttl(@lock.key) > 10, 'TTL should have been updated'
  end

  test 'checking the lock should not increase the TTL if we do not hold it' do
    Resque.redis.setex(@lock.key, 10, @lock.value)
    lock_is_not_held(@lock)

    @lock.locked?

    assert Resque.redis.ttl(@lock.key) <= 10,
           'TTL should not have been updated'
  end
end

context 'Resque::Scheduler::Lock::Resilient' do
  include LockTestHelper

  if !Resque::Scheduler.supports_lua?
    puts '*** Skipping Resque::Scheduler::Lock::Resilient ' \
         'tests, as they require Redis >= 2.5.'
  else
    setup do
      @lock = Resque::Scheduler::Lock::Resilient.new('test_resilient_lock')
    end

    teardown do
      @lock.release!
    end

    test 'you should not have the lock if someone else holds it' do
      lock_is_not_held(@lock)

      assert !@lock.locked?, 'you should not have the lock'
    end

    test 'you should not be able to acquire the lock if someone ' \
         'else holds it' do
      lock_is_not_held(@lock)

      assert !@lock.acquire!
    end

    test 'the lock should receive a TTL on acquiring' do
      @lock.acquire!

      assert Resque.redis.ttl(@lock.key) > 0, 'lock should expire'
    end

    test 'releasing should release the master lock' do
      assert @lock.acquire!, 'should have acquired the master lock'
      assert @lock.locked?, 'should be locked'

      @lock.release!

      assert !@lock.locked?, 'should not be locked'
    end

    test 'checking the lock should increase the TTL if we hold it' do
      @lock.acquire!
      Resque.redis.setex(@lock.key, 10, @lock.value)

      @lock.locked?

      assert Resque.redis.ttl(@lock.key) > 10, 'TTL should have been updated'
    end

    test 'checking the lock should not increase the TTL if we do ' \
         'not hold it' do
      Resque.redis.setex(@lock.key, 10, @lock.value)
      lock_is_not_held(@lock)

      @lock.locked?

      assert Resque.redis.ttl(@lock.key) <= 10,
             'TTL should not have been updated'
    end

    test 'setting the lock timeout changes the key TTL if we hold it' do
      @lock.acquire!

      @lock.stubs(:locked?).returns(true)
      @lock.timeout = 120
      ttl = Resque.redis.ttl(@lock.key)
      assert_send [ttl, :>, 100]

      @lock.stubs(:locked?).returns(true)
      @lock.timeout = 180
      ttl = Resque.redis.ttl(@lock.key)
      assert_send [ttl, :>, 120]
    end

    test 'setting lock timeout is a noop if not held' do
      @lock.acquire!
      @lock.timeout = 100
      @lock.stubs(:locked?).returns(false)
      @lock.timeout = 120
      assert_equal 100, @lock.timeout
    end

    test 'setting lock timeout nils out lock script' do
      @lock.acquire!
      @lock.timeout = 100
      assert_equal nil, @lock.instance_variable_get(:@locked_sha)
    end

    test 'setting lock timeout does not nil out lock script if not held' do
      @lock.acquire!
      @lock.locked?
      @lock.stubs(:locked?).returns(false)
      @lock.timeout = 100
      assert_not_nil @lock.instance_variable_get(:@locked_sha)
    end

    test 'setting lock timeout nils out acquire script' do
      @lock.acquire!
      @lock.timeout = 100
      assert_equal nil, @lock.instance_variable_get(:@acquire_sha)
    end

    test 'setting lock timeout does not nil out acquire script if not held' do
      @lock.acquire!
      @lock.stubs(:locked?).returns(false)
      @lock.timeout = 100
      assert_not_nil @lock.instance_variable_get(:@acquire_sha)
    end
  end
end
