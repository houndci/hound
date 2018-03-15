# frozen_string_literal: true

require "rails_helper"

describe RebuildPullRequest do
  describe "#call" do
    context "when a latest build exists" do
      it "schedules a small build job" do
        repo = create(:repo)
        payload = "{}"
        create(
          :build,
          repo: repo,
          payload: payload,
          pull_request_number: 42,
        )
        rebuilder = RebuildPullRequest.new(repo: repo, pull_request_number: 42)
        allow(SmallBuildJob).to receive(:perform_later)

        rebuilder.call

        expect(SmallBuildJob).to have_received(:perform_later).with(payload)
      end
    end

    context "when a latest build does not exist" do
      it "does not schedule a job" do
        repo = create(:repo)
        payload = "{}"
        create(
          :build,
          repo: repo,
          payload: payload,
          pull_request_number: 42,
        )
        rebuilder = RebuildPullRequest.new(repo: repo, pull_request_number: 100)
        allow(SmallBuildJob).to receive(:perform_later)

        rebuilder.call

        expect(SmallBuildJob).not_to have_received(:perform_later)
      end
    end
  end
end
