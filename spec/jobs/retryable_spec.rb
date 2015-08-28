require "spec_helper"
require "active_job"
require "lib/ext/active_job/base"
require "app/jobs/retryable"

describe Retryable do
  context "a successful job" do
    class RetryableTestJob < ActiveJob::Base
      include Retryable

      def perform
      end
    end

    it "does nothing" do
      allow(RetryableTestJob.queue_adapter).to receive(:enqueue)

      RetryableTestJob.perform_now

      expect(RetryableTestJob.queue_adapter).not_to have_received(:enqueue)
    end
  end

  context "a failing job" do
    class RetryableFailingJob < ActiveJob::Base
      include Retryable

      cattr_accessor :counter

      def perform
        self.counter ||= 0
        self.counter += 1

        if self.counter < 3
          raise
        end
      end
    end

    before do
      RetryableFailingJob.counter = 0
    end

    it "retries until it exhausts the attempts" do
      allow(Retryable).to receive(:retry_delay).and_return(nil)
      allow(Retryable).to receive(:retry_attempts).and_return(2)

      expect do
        RetryableFailingJob.perform_later
      end.to raise_error(RuntimeError)

      expect(RetryableFailingJob.counter).to eq(2)
    end

    it "retries until it passes" do
      allow(Retryable).to receive(:retry_delay).and_return(nil)
      allow(Retryable).to receive(:retry_attempts).and_return(3)

      RetryableFailingJob.perform_later

      expect(RetryableFailingJob.counter).to eq(3)
    end

    it "retries the job with the configured wait" do
      allow(Retryable).to receive(:retry_attempts).and_return(2)
      allow(Retryable).to receive(:retry_delay).and_return(10)
      job = RetryableFailingJob.new
      allow(job).to receive(:retry_job)

      job.perform_now

      expect(job).to have_received(:retry_job).with(wait: 10)
    end
  end
end
