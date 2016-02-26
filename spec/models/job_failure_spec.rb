require 'resque'
require 'app/models/job_failure'

describe JobFailure do
  describe ".all" do
    it "returns an array of indexed job failures" do
      failure1 = { "error" => "Failure 1" }
      failure2 = { "error" => "Failure 2" }
      populate_failures([failure1, failure2])

      job_failures = JobFailure.all

      expect(job_failures.first.index).to eq 0
      expect(job_failures.last.index).to eq 1
    end
  end

  describe "#index" do
    it "returns the index of the job in the backend list" do
      job_failure = JobFailure.new("index" => 5)

      expect(job_failure.index).to eq 5
    end
  end

  describe "#error" do
    it "returns the error of the job in the backend list" do
      job_failure = JobFailure.new("error" => "test error message")

      expect(job_failure.error).to eq("test error message")
    end
  end

  def populate_failures(failures)
    allow(Resque::Failure).to receive(:all).and_return(failures)
  end
end
