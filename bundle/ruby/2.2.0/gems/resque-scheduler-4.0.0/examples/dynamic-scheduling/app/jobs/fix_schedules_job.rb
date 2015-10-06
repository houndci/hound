# vim:fileencoding=utf-8
#
# Background job to fix the schedule for email sending. Any missing
# schedule will be added to resque-schedule.
#
# Recent resque-scheduler versions wipe all dynamic schedules when
# restarting. This means all dynamic schedules, which are added via the
# API, are wiped on each application redeployment. A workaround for this
# sometimes undesirable behavior is to make this job part of a static
# schedule (see config/initializers/resque.rb and
# config/static_schedule.yml).  This job will be scheduled to run every
# hour even after restarting resque-schedule, and will add back the
# dynamic schedules that were wiped on restart. It also serves as
# safeguard against schedules getting lost for any reason.
#
# For more detail about this unfortunate behavior of resque-scheduler see:
#
#   https://github.com/resque/resque-scheduler/issues/269
#
# The perform method of this class will be invoked from a Resque worker.

class FixSchedulesJob
  @queue = :send_emails

  # Fix email sending schedules. Any user which does not have scheduled
  # sending of emails will be detected, and the missing scheduled job
  # will be added to resque-schedule.
  #
  # This method is intended to be invoked from Resque, which means it is
  # performed in the background.
  def self.perform
    users_unscheduled = []

    User.all.each do |user|
      # get schedule for the user
      schedule = Resque.fetch_schedule("send_email_#{user.id}")
      # if a user has no schedule, add it to the array
      users_unscheduled << user if schedule.nil?
    end

    if users_unscheduled.length > 0
      users_unscheduled.each do |user|
        name = "send_email_#{user.id}"
        config = {}
        config[:class] = 'SendEmailJob'
        config[:args] = user.id
        config[:every] = '1d'
        Resque.set_schedule(name, config)
      end
    end
  end
end
