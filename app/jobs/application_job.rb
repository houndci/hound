class ApplicationJob < ActiveJob::Base
  include Retryable

  cattr_accessor :timeout

  rescue_from(Octokit::Unauthorized) do |exception|
    raise exception
  end

  around_perform do |_, block|
    Timeout::timeout(ApplicationJob.timeout, &block)
  end

  around_perform do |_, block|
    begin
      block.call
    rescue Resque::TermException
      retry_job
    end
  end
end
