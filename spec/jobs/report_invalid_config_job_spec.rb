require "rails_helper"

describe ReportInvalidConfigJob do
  describe ".perform" do
    it "calls the `ReportInvalidConfig` service" do
      attributes = {
        "pull_request_number" => "42",
        "commit_sha" => "abc123",
        "linter_name" => "ruby",
        "message" => "Could not parse the given config file",
      }
      allow(ReportInvalidConfig).to receive(:run)

      ReportInvalidConfigJob.perform(attributes)

      expect(ReportInvalidConfig).to have_received(:run).with(
        pull_request_number: attributes["pull_request_number"],
        commit_sha: attributes["commit_sha"],
        linter_name: attributes["linter_name"],
        message: attributes["message"],
      )
    end
  end
end
