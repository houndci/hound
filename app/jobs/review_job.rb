class ReviewJob < ActiveJob::Base
  def perform(build_worker, file, violations)
    Reviewer.run(build_worker, file, violations)
  end
end
