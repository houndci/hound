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
    it "comments on newly found violations" do
      existing_violation_comment = {
        body: "Line is too long.",
        position: 5,
        path: "path/to/test_github_file.rb",
      }
      existing_violation = {
        line: 5,
        message: "Line is too long.",
        source: "# nooooooooooooooooooooooooooooooooooooooooooooooooo",
      }
      new_violation1 = {
        line: 3,
        message: "Trailing whitespace detected.",
        source: "def wat ",
      }
      new_violation2 = {
        line: 9,
        message: "Avoid empty else-clauses.",
        source: "if true; 'yay'; else; end",
      }
      violations = [new_violation1, existing_violation, new_violation2]
      create(:repo, :active, github_id: repo_id, name: repo_name)
      stub_review_job(violations: violations, error: "invalid config syntax")
      FakeGitHub.comments = [existing_violation_comment]

      post builds_path, params: { payload: payload }

      expect(FakeGitHub.review_body).to eq <<~EOS.chomp
        Some files could not be reviewed due to errors:
        <details>
        <summary>invalid config syntax</summary>
        <pre>invalid config syntax</pre>
        </details>
      EOS
      expect(FakeGitHub.comments).to match_array [
        existing_violation_comment,
        {
          body: new_violation1[:message] << "<br>\n```suggestion\ndef wat\n```",
          path: "path/to/test_github_file.rb",
          position: new_violation1[:line],
          pr_number: "1",
          repo: "Hello-World",
        },
        {
          body: new_violation2[:message],
          path: "path/to/test_github_file.rb",
          position: new_violation2[:line],
          pr_number: "1",
          repo: "Hello-World",
        },
      ]
    end
  end

  context "without violations" do
    it "does not make a comment" do
      create(:repo, github_id: repo_id, name: repo_name)

      post builds_path, params: { payload: payload }

      expect(FakeGitHub.comments).to be_empty
    end
  end

  def stub_review_job(violations:, error:)
    allow(LintersJob).to receive(:perform_async) do |attributes|
      CompleteFileReview.call(
        commit_sha: attributes.fetch(:commit_sha),
        filename:  attributes.fetch(:filename),
        linter_name:  attributes.fetch(:linter_name),
        patch:  attributes.fetch(:patch),
        pull_request_number:  attributes.fetch(:pull_request_number),
        violations:  violations,
        error:  error,
      )
    end
  end
end
