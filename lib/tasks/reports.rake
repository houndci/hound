namespace :reports do
  desc "Run all reports"
  task all: [:north_star, :users, :builds, :subscriptions, :cancellations]

  desc "Prints out number of repos with builds per week."
  task north_star: :environment do
    Report.north_star
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
