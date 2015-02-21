require 'resque-retry'

module Retryable
  extend Resque::Plugins::Retry

  @retry_limit = 10
  @retry_delay = ENV.fetch("RESQUE_RETRY_DELAY", 30).to_i
  @fatal_exceptions = [Octokit::Unauthorized]
end
