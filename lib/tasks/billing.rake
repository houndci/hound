namespace :billing do
  desc "Report on paying customers, their usage, and current plan(s)"
  task report: :environment do
    owner_results = Owner.connection.execute(<<~SQL)
      select count(*) as builds, owners.name, owners.organization, owners.whitelisted, owners.marketplace_plan_id from builds
      join repos on repos.id = builds.repo_id
      join owners on owners.id = repos.owner_id
      where DATE(builds.created_at) > DATE(now() - interval '30 days')
        and DATE(builds.created_at) < DATE(now())
        and repos.private = true --and repos.active = true
      group by owners.id
      order by builds DESC
    SQL

    owner_results.each do |owner_result|
      stripe_subscription_results = Owner.connection.execute(<<~SQL)
        select subscriptions.stripe_subscription_id from owners
        join repos on repos.owner_id = owners.id
        join subscriptions on subscriptions.repo_id = repos.id
        where owners.name = '#{owner_result["name"]}'
          and repos.private = true
        group by subscriptions.stripe_subscription_id
      SQL

      puts "#{owner_result["name"]}"
      puts " - #{owner_result["builds"]} builds"
      puts " - Whitelisted? #{owner_result["whitelisted"] ? "Yes" : "No"}"
      puts " - Marketplace? #{owner_result["marketplace_plan_id"] ? "Yes" : "No"}"

      stripe_subscription_results.each do |stripe_subscription_result|
        stripe_sub = Stripe::Subscription.retrieve(stripe_subscription_result["stripe_subscription_id"])

        if stripe_sub.status == "active"
          puts " - #{stripe_sub.plan.nickname} $#{stripe_sub.plan.amount / 100} (#{stripe_sub.id})"
        end
      end

      puts "\n"
    end
  end
end
