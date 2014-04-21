require 'resque-retry'

module Retryable
  extend Resque::Plugins::Retry

  @retry_limit = 10
  @retry_delay = 120
  @fatal_exceptions = [Octokit::NotFound, Octokit::Unauthorized]
end
