require "app/services/submit_review"
require "app/policies/commenting_policy"
require "app/models/review_body"
require "lib/github_api"

RSpec.describe SubmitReview do
  describe ".call" do
    it "posts a review with max comments to GitHub" do
      stub_const("Hound::MAX_COMMENTS", 2)
      stub_const("Hound::GITHUB_TOKEN", "some-token")
      violation1 = stub_violation("foo comment")
      violation2 = stub_violation("bar comment")
      violation3 = stub_violation("baz comment")
      build = stub_build(
        violations: [violation1, violation2, violation3],
        review_errors: ["invalid config", "foo\n  bar"],
      )
      github = stub_github

      described_class.call(build)

      expect(github).to have_received(:create_pull_request_review).with(
        build.repo_name,
        build.pull_request_number,
        [
          {
            path: violation1.filename,
            position: violation1.patch_position,
            body: violation1.messages.join,
          },
          {
            path: violation2.filename,
            position: violation2.patch_position,
            body: violation2.messages.join,
          },
        ],
        <<~TEXT.chomp
          Some files could not be reviewed due to errors:
          <details>
          <summary>invalid config</summary>
          <pre>invalid config</pre>
          </details>
          <details>
          <summary>foo</summary>
          <pre>foo
            bar</pre>
          </details>
        TEXT
      )
    end

    context "with existing violations" do
      it "makes comments only for new violations" do
        stub_const("Hound::MAX_COMMENTS", 5)
        stub_const("Hound::GITHUB_TOKEN", "some-token")
        violation1 = stub_violation("foo")
        violation2 = stub_violation("bar")
        build = stub_build(violations: [violation1, violation2])
        existing_comment = build_comment(
          filename: violation1.filename,
          body: violation1.messages.first,
        )
        github = stub_github(comments: [existing_comment])

        described_class.call(build)

        expect(github).to have_received(:create_pull_request_review).with(
          build.repo_name,
          build.pull_request_number,
          [hash_including(body: violation2.messages.first)],
          "",
        )
      end
    end
  end

  def stub_violation(message)
    instance_double(
      "Violation",
      filename: "test.rb",
      messages: [message],
      patch_position: 1,
    )
  end

  def build_comment(filename:, body:)
    double("GitHubComment", path: filename, position: 1, body: body)
  end

  def stub_build(violations:, review_errors: [])
    instance_double(
      "Build",
      repo_name: "org/repo",
      pull_request_number: 55,
      violations: violations,
      review_errors: review_errors,
    )
  end

  def stub_github(comments: [])
    github = instance_double(
      "GitHubApi",
      pull_request_comments: comments,
      create_pull_request_review: nil,
    )
    allow(GitHubApi).to receive(:new).and_return(github)
    github
  end
end
