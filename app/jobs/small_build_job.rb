require 'octokit'

class SmallBuildJob
  extend Retryable
  extend Buildable

  @queue = :medium
end
