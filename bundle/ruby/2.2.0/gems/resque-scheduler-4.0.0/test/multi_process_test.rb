# vim:fileencoding=utf-8
require_relative 'test_helper'

context 'Multi Process' do
  test 'setting schedule= from many process does not corrupt the schedules' do
    schedules = {}
    counts  = []
    threads = []

    # This number may need to be increased if this test is not failing
    processes = 20

    schedule_count = 200

    schedule_count.times do |n|
      schedules["job #{n}"] = { cron: '0 1 0 0 0' }
    end

    processes.times do |n|
      threads << Thread.new do
        sleep n * 0.1
        Resque.schedule = schedules
        counts << Resque.schedule.size
      end
    end

    # doing this outside the threads increases the odds of failure
    Resque.schedule = schedules
    counts << Resque.schedule.size

    threads.each(&:join)

    counts.each_with_index do |c, i|
      assert_equal schedule_count, c, "schedule count is incorrect (c: #{i})"
    end
  end
end
