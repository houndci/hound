require "rails_helper"

describe Buildable do
  class BuildableTestJob < ActiveJob::Base
    include Buildable
  end

  describe "#perform" do
    it 'runs build runner' do
      payload = stub_payload(payload_data)
      allow(BuildRunner).to receive(:call)

      BuildableTestJob.perform_now(payload_data)

      expect(Payload).to have_received(:new).with(payload_data)
      expect(BuildRunner).to have_received(:call).with(payload)
    end

    it "runs repo updater" do
      payload = stub_payload(payload_data)
      allow(UpdateRepoStatus).to receive(:call)

      BuildableTestJob.perform_now(payload_data)

      expect(Payload).to have_received(:new).with(payload_data)
      expect(UpdateRepoStatus).to have_received(:call).with(payload)
    end

    context "when the pull request has been blacklisted" do
      it "does not set the status" do
        payload_data = payload_data(full_name: "ignore/me", number: 42)
        create(
          :blacklisted_pull_request,
          full_repo_name: "ignore/me",
          pull_request_number: 42,
        )
        allow(UpdateRepoStatus).to receive(:new)

        BuildableTestJob.perform_now(payload_data)

        expect(UpdateRepoStatus).not_to have_received(:new)
      end

      it "does not run the build" do
        payload_data = payload_data(full_name: "ignore/me", number: 42)
        create(
          :blacklisted_pull_request,
          full_repo_name: "ignore/me",
          pull_request_number: 42,
        )
        allow(BuildRunner).to receive(:new)

        BuildableTestJob.perform_now(payload_data)

        expect(BuildRunner).not_to have_received(:new)
      end
    end
  end

  describe "#after_retry_exhausted" do
    it "sets internal server error on github" do
      build_runner = double("BuildRunner", set_internal_error: nil)
      payload = double("Payload")
      allow(Payload).to receive(:new).with(payload_data).and_return(payload)
      allow(BuildRunner).to receive(:new).and_return(build_runner)

      BuildableTestJob.new(payload_data).after_retry_exhausted

      expect(Payload).to have_received(:new).with(payload_data)
      expect(BuildRunner).to have_received(:new).with(payload)
      expect(build_runner).to have_received(:set_internal_error)
    end
  end

  def payload_data(
    github_id: 1234,
    name: "test",
    full_name: "user/repo",
    number: 1
  )
    {
      "number" => number,
      "repository" => {
        "full_name" => full_name,
        "owner" => {
          "id" => github_id,
          "login" => name,
          "type" => "Organization"
        }
      }
    }
  end

  def stub_payload(payload_data)
    payload = double(
      Payload,
      github_repo_id: 1,
      full_repo_name: "user/repo",
      pull_request_number: 1,
    )
    allow(Payload).to receive(:new).with(payload_data).and_return(payload)
    payload
  end
end
