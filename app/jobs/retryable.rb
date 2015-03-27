require 'resque-retry'

module Retryable
  extend Resque::Plugins::Retry

  @retry_limit = 10
  @retry_delay = RESQUE_RETRY_DELAY
  @fatal_exceptions = [Octokit::Unauthorized]
end
