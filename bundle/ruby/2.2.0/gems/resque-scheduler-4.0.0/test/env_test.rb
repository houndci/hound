# vim:fileencoding=utf-8
require_relative 'test_helper'

context 'Env' do
  def new_env(options = {})
    Resque::Scheduler::Env.new(options)
  end

  test 'daemonizes when background is true' do
    Process.expects(:daemon)
    env = new_env(background: true)
    env.setup
  end

  test 'reconnects redis when background is true' do
    Process.stubs(:daemon)
    mock_redis_client = mock('redis_client')
    mock_redis = mock('redis')
    mock_redis.expects(:client).returns(mock_redis_client)
    mock_redis_client.expects(:reconnect)
    Resque.expects(:redis).returns(mock_redis)
    env = new_env(background: true)
    env.setup
  end

  test 'aborts when background is given and Process does not support daemon' do
    Process.stubs(:daemon)
    Process.expects(:respond_to?).with('daemon').returns(false)
    env = new_env(background: true)
    env.expects(:abort)
    env.setup
  end

  test 'keep set config if no option given' do
    Resque::Scheduler.configure { |c| c.dynamic = true }
    env = new_env
    env.setup
    assert_equal(true, Resque::Scheduler.dynamic)
  end

  test 'override config if option given' do
    Resque::Scheduler.configure { |c| c.dynamic = true }
    env = new_env(dynamic: false)
    env.setup
    assert_equal(false, Resque::Scheduler.dynamic)
  end
end
