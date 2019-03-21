require "sidekiq/api"
require "active_model/naming"
require "app/models/job_failure"

RSpec.describe JobFailure do
  describe ".all" do
    it "returns an array of job failures" do
      failure1 = {
        "jid" => "abc123",
        "error_message" => "foo",
        "wrapped" => "SomeJob",
      }
      failure2 = {
        "jid" => "def456",
        "error_message" => "bar",
        "wrapped" => "SomeOtherJob",
      }
      populate_failures [
        OpenStruct.new(item: failure1),
        OpenStruct.new(item: failure2),
      ]

      job_failures = JobFailure.all

      expect(job_failures).to match [
        JobFailure.new(failure1),
        JobFailure.new(failure2),
      ]
    end
  end

  describe ".remove" do
    it "removes the jobs from Sidekiq" do
      job_failure1 = instance_double(
        "Sidekiq::SortedEntry",
        item: { "jid" => "foo", "error_message" => "foo error message" },
        delete: nil,
      )
      job_failure2 = instance_double(
        "Sidekiq::SortedEntry",
        item: { "jid" => "bar", "error_message" => "bar error message" },
        delete: nil,
      )
      failure_set = instance_double(
        "Sidekiq::DeadSet",
        map: [
          OpenStruct.new(item: job_failure1),
          OpenStruct.new(item: job_failure2),
        ],
        find_job: job_failure1,
      )
      allow(failure_set).to receive(:find_job).
        and_return(job_failure1, job_failure2)
      populate_failures(failure_set)

      JobFailure.remove(["foo", "bar"])

      expect(failure_set).to have_received(:find_job).with("foo")
      expect(failure_set).to have_received(:find_job).with("bar")
      expect(job_failure1).to have_received(:delete)
      expect(job_failure2).to have_received(:delete)
    end
  end

  def populate_failures(failures)
    allow(Sidekiq::DeadSet).to receive(:new).and_return(failures)
  end
end
