require "spec_helper"

describe Buildable do
  class TestJob
    extend Buildable
  end

  describe '.perform' do
    it 'runs build runner' do
      build_runner = double(:build_runner, run: nil)
      payload = double(
        "Payload",
        repository_owner_id: 1,
        repository_owner_name: "test",
        repository_owner_is_organization?: true
      )
      allow(Payload).to receive(:new).and_return(payload)
      allow(BuildRunner).to receive(:new).and_return(build_runner)
      allow(Owner).to receive(:upsert)

      TestJob.perform(payload_data)

      expect(Payload).to have_received(:new).with(payload_data)
      expect(BuildRunner).to have_received(:new).with(payload)
      expect(build_runner).to have_received(:run)
    end

    it 'retries when Resque::TermException is raised' do
      allow(Payload).to receive(:new).and_raise(Resque::TermException.new(1))
      allow(Resque).to receive(:enqueue)

      TestJob.perform(payload_data)

      expect(Resque).to have_received(:enqueue).with(TestJob, payload_data)
    end

    it "upserts repository owner" do
      github_id = "2345"
      name = "thoughtbot"
      payload_data = payload_data(
        github_id: github_id,
        name: name
      )
      build_runner = double("BuildRunner", run: true)
      allow(BuildRunner).to receive(:new).and_return(build_runner)
      allow(Owner).to receive(:upsert)

      TestJob.perform(payload_data)

      expect(Owner).to have_received(:upsert).with(
        github_id: github_id,
        name: name,
        organization: true
      )
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
