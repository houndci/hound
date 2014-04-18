require 'octokit'

class LargeBuildJob
  extend Retryable
  extend Buildable

  @queue = :low
end
