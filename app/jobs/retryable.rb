module Retryable
  extend ActiveSupport::Concern

  mattr_accessor :retry_delay, :retry_attempts

  included do
    rescue_from(StandardError) do |exception|
      if attempts >= Retryable.retry_attempts
        after_retry_attempts
        raise exception
      end

      retry_job wait: Retryable.retry_delay
    end
  end

  def serialize
    super.merge("attempts" => attempts + 1)
  end

  def deserialize(job_data)
    super
    @attempts = job_data["attempts"]
  end

  def attempts
    @attempts ||= 0
  end

  def after_retry_attempts
    if respond_to?(:after_retry_exhausted)
      after_retry_exhausted
    end
  end
end
