require "fast_spec_helper"
require "app/jobs/buildable"
require "app/models/payload"
require "app/services/build_runner"
require "raven"

describe Buildable do
  class TestJob
    extend Buildable
  end

  describe '.perform' do
    it 'runs build runner' do
      stub_const("Owner", "foo")
      build_runner = double(:build_runner, run: nil)
      payload_data = "some data"
      payload = double("Payload")
      allow(Payload).to receive(:new).with(payload_data).and_return(payload)
      allow(BuildRunner).to receive(:new).and_return(build_runner)
      allow(Owner).to receive(:upsert)

      TestJob.perform(payload_data)

      expect(Payload).to have_received(:new).with(payload_data)
      expect(BuildRunner).to have_received(:new).with(payload)
      expect(build_runner).to have_received(:run)
    end

    it "retries when Resque::TermException is raised" do
      allow(Payload).to receive(:new).and_raise(Resque::TermException.new(1))
      allow(Resque).to receive(:enqueue)

      TestJob.perform("payload")

      expect(Resque).to have_received(:enqueue).with(TestJob, "payload")
    end

    it "sends the exception to Sentry with the user_id" do
      exception = StandardError.new("hola")
      allow(Payload).to receive(:new).and_raise(exception)
      allow(Raven).to receive(:capture_exception)
      payload_data = double("PayloadData")

      TestJob.perform(payload_data)

      expect(Raven).to have_received(:capture_exception).
        with(exception, payload: { data: payload_data })
    end
  end

  def payload_data(github_id: 1234, name: "test")
    {
      "repository" => {
        "owner" => {
          "id" => github_id,
          "login" => name,
          "type" => "Organization"
        }
      }
    }
  end
end
