require "rails_helper"

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
    class ParentJob < ActiveJob::Base
      include Retryable

      mattr_accessor :exhausted, :counter

      def perform
        self.counter ||= 0
        self.counter += 1

        if counter < 3
          raise "max attempts"
        end
      end
    end

    class RetryableFailingJob < ParentJob
    end

    class ExhaustedJob < ParentJob
      def after_retry_exhausted
        self.exhausted = true
      end
    end

    before do
      RetryableFailingJob.counter = 0
      RetryableFailingJob.exhausted = nil
    end

    it "retries until it exhausts the attempts" do
      allow(Retryable).to receive(:retry_delay).and_return(nil)
      allow(Retryable).to receive(:retry_attempts).and_return(2)

      expect { RetryableFailingJob.perform_later }.to raise_error(RuntimeError)

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

    context "when `after_retry_exhausted` exists" do
      it "calls `after_retry_exhausted` after retrying" do
        job = ExhaustedJob.new
        allow(Retryable).to receive(:retry_attempts).and_return(1)
        allow(job).to receive(:after_retry_exhausted).and_return(true)

        expect { job.perform_now }.to raise_error "max attempts"
        expect(job.exhausted).to be true
      end
    end

    context "when `after_retry_exhausted` does not exists" do
      it "does not call it" do
        allow(Retryable).to receive(:retry_attempts).and_return(1)
        job = RetryableFailingJob.new

        expect { job.perform_now }.to raise_error "max attempts"
        expect(RetryableFailingJob.exhausted).to be nil
      end
    end
  end
end
