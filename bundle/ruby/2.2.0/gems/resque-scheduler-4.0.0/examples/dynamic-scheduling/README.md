Dynamic Scheduling Example
==========================

Possible workaround for
https://github.com/resque/resque-scheduler/issues/269

This folder contains just the relevant files you would have to put into
a rails application.

The problem we want to fix is that when resque-scheduler is restarted,
any dynamically added jobs are wiped. To fix it, we will run a
statically scheduled job that dynamically reschedules any missing
dynamic schedules.

This workaround uses both a dynamic schedule (every time a user is
created, a schedule is dynamically added to send him a daily email) and
a static schedule (a job runs hourly, starting 10 seconds after starting
resque-scheduler, to check that there is a scheduled job to send an
email for every user; missing schedules are added).

This way even though a resque-scheduler restart wipes all dynamic
schedules, they are recreated by the `fix_schedules` job that runs in
the static schedule.  Even if dynamic schedules were lost for any reason
(data loss in redis clusters, whatever), they will be recreated hourly.

This workaround requires that enough information is saved in the
database to recreate all dynamic schedules. In this case we create one
dynamically scheduled job for every user in the database.
