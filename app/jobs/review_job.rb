class ReviewJob < ActiveJob::Base
  def perform(build_worker, file, violations)
    Review.run(build_worker, file, violations)
  end
end
