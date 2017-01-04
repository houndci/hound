require "rails_helper"

RSpec.describe "POST /builds" do
  let(:payload) do
    File.read("spec/support/fixtures/pull_request_opened_event.json")
  end
  let(:parsed_payload) { JSON.parse(payload) }
  let(:repo_name) { parsed_payload["repository"]["full_name"] }
  let(:repo_id) { parsed_payload["repository"]["id"] }
  let(:pr_sha) { parsed_payload["pull_request"]["head"]["sha"] }
  let(:pr_number) { parsed_payload["number"] }

  context "with violations" do
    it "makes a new comment and cleans up resolved one" do
      existing_comment_violation = { line: 5, message: "Line is too long." }
      new_violation = { line: 9, message: "Trailing whitespace detected." }
      violations = [existing_comment_violation, new_violation]
      create(:repo, :active, github_id: repo_id, name: repo_name)
      stub_review_job(RubocopReviewJob, violations: violations)

      post builds_path, params: { payload: payload }

      comments = FakeGithub.comments
      comment = comments.first
      expect(comments.size).to eq 1
      expect(comment).to have_attributes(
        body: "Trailing whitespace detected.",
        commit_id: pr_sha,
        path: "path/to/test_github_file.rb",
        position: 9,
        pull_id: "2",
        repo: "life",
      )
    end
  end

  context "without violations" do
    it "does not make a comment" do
      create(:repo, github_id: repo_id, name: repo_name)

      post builds_path, params: { payload: payload }

      expect(FakeGithub.comments).to be_empty
    end
  end

  def stub_review_job(klass, violations:)
    allow(klass).to receive(:perform) do |attributes|
      CompleteFileReview.run(
        "commit_sha" => attributes.fetch("commit_sha"),
        "filename" => attributes.fetch("filename"),
        "linter_name" => attributes.fetch("linter_name"),
        "patch" => attributes.fetch("patch"),
        "pull_request_number" => attributes.fetch("pull_request_number"),
        "violations" => violations.map(&:stringify_keys),
      )
    end
  end
end
