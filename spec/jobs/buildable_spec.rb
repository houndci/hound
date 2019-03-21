require "rails_helper"

RSpec.describe Buildable do
  class BuildableTestJob < ApplicationJob
    include Buildable
  end

  describe "#perform" do
    it "runs build runner" do
      payload = stub_payload(payload_data)
      allow(StartBuild).to receive(:call)

      BuildableTestJob.perform_async(payload_data)

      expect(Payload).to have_received(:new).with(payload_data)
      expect(StartBuild).to have_received(:call).with(payload)
    end

    it "runs repo updater" do
      payload = stub_payload(payload_data)
      allow(UpdateRepoStatus).to receive(:call)

      BuildableTestJob.perform_async(payload_data)

      expect(Payload).to have_received(:new).with(payload_data)
      expect(UpdateRepoStatus).to have_received(:call).with(payload)
    end

    context "when the pull request has been blacklisted" do
      it "does not set the status" do
        payload_data = payload_data(repo_name: "ignore/me", pr_number: 42)
        create(
          :blacklisted_pull_request,
          full_repo_name: "ignore/me",
          pull_request_number: 42,
        )
        allow(UpdateRepoStatus).to receive(:new)

        BuildableTestJob.perform_async(payload_data)

        expect(UpdateRepoStatus).not_to have_received(:new)
      end

      it "does not run the build" do
        payload_data = payload_data(repo_name: "ignore/me", pr_number: 42)
        create(
          :blacklisted_pull_request,
          full_repo_name: "ignore/me",
          pull_request_number: 42,
        )
        allow(StartBuild).to receive(:new)

        BuildableTestJob.perform_async(payload_data)

        expect(StartBuild).not_to have_received(:new)
      end
    end
  end

  def payload_data(github_id: 1234, repo_name: "user/repo", pr_number: 1)
    {
      "number" => pr_number,
      "repository" => {
        "id" => github_id,
        "full_name" => repo_name,
        "owner" => {
          "login" => "foo",
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
