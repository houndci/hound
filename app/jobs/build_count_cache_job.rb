class BuildCountCacheJob < ApplicationJob
  sidekiq_options queue: :low

  def perform(owner_id)
    Owner.find(owner_id).recent_build_count(clear_cache: true)
  end
end
