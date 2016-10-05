namespace :stripe do
  desc "Backfill stripe metadata with repo information"
  task backfill_metadata: :environment do
    UpdateStripeMetadata.run
  end

  desc "Upgrade users to tiered pricing"
  task upgrade_to_tiered_pricing: :environment do
    bar = RakeProgressbar.new(User.count)

    User.all.each do |user|
      TieredSubscriptionsMigrator.migrate!(user)
      bar.inc
    end

    bar.finished
  end
end
