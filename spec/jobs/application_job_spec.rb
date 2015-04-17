require "rails_helper"

describe ApplicationJob do
  it "is retryable" do
    expect(ApplicationJob.new).to be_a(Retryable)
  end

  it "times out slow jobs" do
    timeout = 10
    allow(ApplicationJob).to receive(:timeout).and_return(timeout)
    allow(Timeout).to receive(:timeout)

    ApplicationJob.perform_now

    expect(Timeout).to have_received(:timeout).with(timeout)
  end

  it "retries on term exception" do
    job = ApplicationJob.new
    allow(job).to receive(:perform).and_raise(Resque::TermException, "HUP")
    allow(job).to receive(:retry_job)

    job.perform_now

    expect(job).to have_received(:retry_job)
  end

  it "does not retry on octokit authorization exception" do
    job = ApplicationJob.new
    allow(job).to receive(:perform).and_raise(Octokit::Unauthorized)
    allow(job).to receive(:retry_job)

    expect { job.perform_now }.to raise_error(Octokit::Unauthorized)

    expect(job).not_to have_received(:retry_job)
  end
end
