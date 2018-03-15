# frozen_string_literal: true

require "rails_helper"

describe UpdateRepoStatus do
  describe "#call" do
    it "updates the repo name" do
      expected_repo_name = "foo/bar"
      repo = create(:repo, :active)
      payload = double(
        "Payload",
        github_repo_id: repo.github_id,
        full_repo_name: expected_repo_name,
        private_repo?: repo.private,
      )

      UpdateRepoStatus.new(payload).call

      repo.reload
      expect(repo.name).to eq(expected_repo_name)
    end

    it "updates the private flag for repo" do
      expected_status = true
      repo = create(:repo, :active)
      payload = double(
        "Payload",
        github_repo_id: repo.github_id,
        full_repo_name: repo.name,
        private_repo?: expected_status,
      )

      UpdateRepoStatus.new(payload).call

      repo.reload
      expect(repo.private).to eq(expected_status)
    end
  end
end
