namespace :stripe do
  desc "Backfill stripe metadata with repo information"
  task backfill_metadata: :environment do
    UpdateStripeMetadata.run
  end
end
