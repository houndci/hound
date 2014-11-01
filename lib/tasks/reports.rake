namespace :reports do
  desc 'Run all reports'
  task all: [:activity, :users, :builds, :subscriptions, :cancellations]

  desc 'Prints out weekly activity, which is the number of repos that had builds during the week.'
  task activity: :environment do
    Report.activity
  end

  desc 'Prints out new user counts by week.'
  task users: :environment do
    Report.users
  end

  desc 'Prints out build counts by week.'
  task builds: :environment do
    Report.builds
  end

  desc 'Prints out new subscription count by week.'
  task subscriptions: :environment do
    Report.subscriptions
  end

  desc 'Prints out new cancellation count by week.'
  task cancellations: :environment do
    Report.cancellations
  end
end
