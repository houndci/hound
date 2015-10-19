require "rails_helper"

describe ReportInvalidConfigJob do
  describe ".perform" do
    it "calls the `ReportInvalidConfig` service" do
      attributes = {
        "pull_request_number" => "42",
        "commit_sha" => "abc123",
        "filename" => "config/.rubocop.yml",
      }
      allow(ReportInvalidConfig).to receive(:run)

      ReportInvalidConfigJob.perform(attributes)

      expect(ReportInvalidConfig).to have_received(:run).with(
        pull_request_number: attributes["pull_request_number"],
        commit_sha: attributes["commit_sha"],
        filename: attributes["filename"],
      )
    end
  end
end
