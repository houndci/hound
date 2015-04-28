class ReviewJob < ActiveJob::Base
  queue_as :medium

  def perform(build_worker, file, violations)
    Review.run(build_worker, file, violations)
  end
end
