namespace :stripe do
  desc "Backfill stripe metadata with repo information"
  task backfill_metadata: :environment do
    UpdateStripeMetadata.run
  end

  desc "Upgrade users to tiered pricing"
  task upgrade_to_tiered_pricing: :environment do
    User.all.each { |user| MigrateTieredSubscriptions.migrate!(user) }
  end
end
