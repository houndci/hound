# vim:fileencoding=utf-8

# ### Locking the scheduler process
#
# There are two places in resque-scheduler that need to be synchonized in order
# to be able to run redundant scheduler processes while ensuring jobs don't get
# queued multiple times when the master process changes.
#
# 1) Processing the delayed queues (jobs that are created from
# enqueue_at/enqueue_in, etc) 2) Processing the scheduled (cron-like) jobs from
# rufus-scheduler
#
# Protecting the delayed queues (#1) is relatively easy.  A simple SETNX in
# redis would suffice.  However, protecting the scheduled jobs is trickier
# because the clocks on machines could be slightly off or actual firing times
# could vary slightly due to load.  If scheduler A's clock is slightly ahead of
# scheduler B's clock (since they are on different machines), when scheduler A
# dies, we need to ensure that scheduler B doesn't queue jobs that A already
# queued before it's death. (This all assumes that it is better to miss a few
# scheduled jobs than it is to run them multiple times for the same iteration.)
#
# To avoid queuing multiple jobs in the case of master fail-over, the master
# should remain the master as long as it can rather than a simple SETNX which
# would result in the master roll being passed around frequently.
#
# Locking Scheme: Each resque-scheduler process attempts to get the master lock
# via SETNX.  Once obtained, it sets the expiration for 3 minutes
# (configurable).  The master process continually updates the timeout on the
# lock key to be 3 minutes in the future in it's loop(s) (see `run`) and when
# jobs come out of rufus-scheduler (see `load_schedule_job`).  That ensures
# that a minimum of 3 minutes must pass since the last queuing operation before
# a new master is chosen.  If, for whatever reason, the master fails to update
# the expiration for 3 minutes, the key expires and the lock is up for grabs.
# If miraculously the original master comes back to life, it will realize it is
# no longer the master and stop processing jobs.
#
# The clocks on the scheduler machines can then be up to 3 minutes off from
# each other without the risk of queueing the same scheduled job twice during a
# master change.  The catch is, in the event of a master change, no scheduled
# jobs will be queued during those 3 minutes.  So, there is a trade off: the
# higher the timeout, the less likely scheduled jobs will be fired twice but
# greater chances of missing scheduled jobs.  The lower the timeout, less
# likely jobs will be missed, greater the chances of jobs firing twice.  If you
# don't care about jobs firing twice or are certain your machines' clocks are
# well in sync, a lower timeout is preferable.  One thing to keep in mind: this
# only effects *scheduled* jobs - delayed jobs will never be lost or skipped
# since eventually a master will come online and it will process everything
# that is ready (no matter how old it is).  Scheduled jobs work like cron - if
# you stop cron, no jobs fire while it's stopped and it doesn't fire jobs that
# were missed when it starts up again.

require_relative 'lock'

module Resque
  module Scheduler
    module Locking
      def master_lock
        @master_lock ||= build_master_lock
      end

      def supports_lua?
        redis_master_version >= 2.5
      end

      def master?
        master_lock.acquire! || master_lock.locked?
      end

      def release_master_lock!
        warn "#{self}\#release_master_lock! is deprecated because it does " \
             "not respect lock ownership. Use #{self}\#release_master_lock " \
             "instead (at #{caller.first}"

        master_lock.release!
      end

      def release_master_lock
        master_lock.release
      end

      private

      def build_master_lock
        if supports_lua?
          Resque::Scheduler::Lock::Resilient.new(master_lock_key)
        else
          Resque::Scheduler::Lock::Basic.new(master_lock_key)
        end
      end

      def master_lock_key
        lock_prefix = ENV['RESQUE_SCHEDULER_MASTER_LOCK_PREFIX'] || ''
        lock_prefix += ':' if lock_prefix != ''
        "#{Resque.redis.namespace}:#{lock_prefix}resque_scheduler_master_lock"
      end

      def redis_master_version
        Resque.redis.info['redis_version'].to_f
      end
    end
  end
end
