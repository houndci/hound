namespace :plan do
  desc "Update marketplace plans for all owners"
  task update_all: :environment do
    UpdateGitHubPlans.call
  end

  desc "Update marketplace plans for all owners"
  task migrate_owners: :environment do
    owners = Repo.joins(:subscription).map(&:owner).uniq
    owners.each do |owner|
      subscription = owner.repos.active.detect(&:subscription).subscription
      stripe_user = subscription.user
      puts "Onwer #{owner.name} mapped to user #{stripe_user.username}"

      owner.update!(
        stripe_customer_id: stripe_user.stripe_customer_id,
        stripe_subscription_id: subscription.stripe_subscription_id,
      )
    end
  end
end
