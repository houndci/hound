require "rails_helper"

RSpec.describe "POST /github_events" do
  it "makes new and deletes outdated comments" do
    payload = File.read("spec/support/fixtures/pull_request_opened_event.json")
    parsed_payload = JSON.parse(payload)
    new_violation = {
      line: 3,
      message: "Trailing whitespace detected.",
      source: "def wat "
    }
    repo = create(
      :repo,
      :active,
      github_id: parsed_payload["repository"]["id"],
      name: "test/org",
      installation_id: 12345,
    )
    outdated_comment = build_comment(repo, "Some outdated comment")
    stub_review_job(violations: [new_violation], error: "invalid config syntax")
    FakeGitHub.comments = [outdated_comment]
    headers = {
      "X-Hub-Signature": "sha1=5864ad853cfc35c5b20349dabd18a815325515c7",
      "X-GitHub-Event": "pull_request",
    }

    post(github_events_path, params: payload, headers: headers)

    expect(FakeGitHub.review_body).to eq <<~GITHUB.chomp
      Some files could not be reviewed due to errors:
      <details>
      <summary>invalid config syntax</summary>
      <pre>invalid config syntax</pre>
      </details>
    GITHUB
    expect(FakeGitHub.comments).to match_array [
      {
        body: new_violation[:message] << "<br>```suggestion\ndef wat\n```",
        path: "path/to/test_github_file.rb",
        position: new_violation[:line],
        pr_number: "1",
        repo: "Hello-World",
      },
    ]
  end

  def build_comment(repo, message)
    {
      id: "abc123",
      body: message,
      path: "path/to/test_github_file.rb",
      position: 3,
      pr_number: "1",
      repo: repo.name,
      user: { type: "Bot", login: "hound[bot]" },
    }
  end

  def stub_review_job(violations:, error:)
    allow(LintersJob).to receive(:perform_async) do |attributes|
      CompleteFileReview.call(
        commit_sha: attributes.fetch(:commit_sha),
        filename: attributes.fetch(:filename),
        linter_name: attributes.fetch(:linter_name),
        patch: attributes.fetch(:patch),
        pull_request_number: attributes.fetch(:pull_request_number),
        violations: violations,
        error: error,
      )
    end
  end
end
