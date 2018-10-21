require "rails_helper"

RSpec.describe CompleteBuild do
  describe ".call" do
    context "when build has violations" do
      context "when fail on violations is disabled" do
        it "sets GitHub status to complete" do
          stubbed_hound_config(fail_on_violations?: false)
          build = stub_build(["foo"])
          github_api = stubbed_github_api

          described_class.call(build)

          expect(github_api).to have_received(:create_success_status).with(
            build.repo_name,
            build.commit_sha,
            "1 violation found.",
          )
        end
      end

      context "when fail on violations is enabled" do
        it "sets GitHub status to failed" do
          build = stub_build(["foo"])
          stubbed_hound_config(fail_on_violations?: true)
          github_api = stubbed_github_api

          described_class.call(build)

          expect(github_api).to have_received(:create_error_status).with(
            build.repo_name,
            build.commit_sha,
            "1 violation found.",
            nil,
          )
        end
      end
    end

    context "when build does not have violations" do
      it "sets GitHub status to complete without comments" do
        build = stub_build([])
        stubbed_hound_config(fail_on_violations?: false)
        github_api = stubbed_github_api

        described_class.call(build)

        expect(github_api).not_to have_received(:create_pull_request_review)
        expect(github_api).to have_received(:create_success_status).with(
          build.repo_name,
          build.commit_sha,
          I18n.t(:complete_status, count: 0),
        )
      end
    end

    context "when build has file review errors" do
      it "adds a comment to pull request review" do
        build = stub_build([], review_errors: ["cannot parse config"])
        github_api = stubbed_github_api

        described_class.call(build)

        expect(github_api).to have_received(:create_pull_request_review).with(
          build.repo_name,
          build.pull_request_number,
          [],
          include("cannot parse config"),
        )
      end
    end

    context "with subscribed private repo and opened pull request" do
      it "tracks build events" do
        repo = create(:repo, :active, github_id: 123, private: true)
        build = create(:build, repo: repo)
        create(:subscription, repo: repo)
        stubbed_github_api

        described_class.call(build)

        expect(analytics).to have_tracked("Build Completed").
          for_user(repo.subscription.user).
          with(properties: { name: repo.name, private: true })
      end
    end

    def stubbed_github_api
      github_api = instance_double(
        "GitHubApi",
        file_contents: double(content: ""),
        create_success_status: nil,
        create_error_status: nil,
        create_installation_token: "foo",
        create_pull_request_review: nil,
        pull_request_comments: [],
      )
      allow(GitHubApi).to receive(:new).and_return(github_api)

      github_api
    end

    def stubbed_hound_config(options = {})
      hound_config = instance_double("HoundConfig", options)
      allow(HoundConfig).to receive(:new).and_return(hound_config)

      hound_config
    end

    def stub_build(violation_messages, attributes = {})
      violations = violation_messages.map do |violation_message|
        instance_double(
          "Violation",
          filename: "app/anything.rb",
          patch_position: 1,
          messages: [violation_message],
        )
      end
      repo = instance_double(
        "Repo",
        name: "foo/bar",
        installation_id: 111,
        subscription: false,
        owner: MissingOwner.new,
      )
      github_auth = instance_double("GitHubAuth", token: "token")
      default_attributes = {
        completed?: true,
        github_auth: github_auth,
        review_errors: [],
        repo_name: repo.name,
        repo: repo,
        commit_sha: "abc123",
        pull_request_number: 321,
        violations: violations,
        violations_count: violations.size,
      }
      instance_double("Build", default_attributes.merge(attributes))
    end
  end
end
