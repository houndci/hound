require "rails_helper"

RSpec.describe CompleteBuild do
  describe ".call" do
    context "when build has violations" do
      context "when the build is complete" do
        context "when fail on violations is disabled" do
          it "sets GitHub status to complete" do
            stubbed_hound_config(fail_on_violations?: false)
            build = stub_build(["foo"])
            github_api = stubbed_github_api

            run_service(build)

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

            run_service(build)

            expect(github_api).to have_received(:create_error_status).with(
              build.repo_name,
              build.commit_sha,
              "1 violation found.",
              nil,
            )
          end
        end
      end

      context "when the build is not complete" do
        it "does not comment and does not set success status" do
          build = stub_build(["foo"], completed?: false)
          pull_request = stub_pull_request
          github_api = stubbed_github_api

          CompleteBuild.call(
            pull_request: pull_request,
            build: build,
            token: "abc123",
          )

          expect(github_api).not_to have_received(:create_pull_request_review)
          expect(github_api).not_to have_received(:create_success_status)
        end
      end
    end

    context "when build does not have violations" do
      it "sets GitHub status to complete without comments" do
        build = stub_build([])
        stubbed_hound_config(fail_on_violations?: false)
        github_api = stubbed_github_api

        run_service(build)

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
        pull_request = stub_pull_request
        github_api = stubbed_github_api

        run_service(build)

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

        run_service(build)

        expect(analytics).to have_tracked("Build Completed").
          for_user(repo.subscription.user).
          with(properties: { name: repo.name, private: true })
      end
    end

    def stubbed_github_api
      github_api = instance_double(
        "GitHubApi",
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
        installation_id: 111,
        subscription: false,
        owner: MissingOwner.new,
      )
      default_attributes = {
        completed?: true,
        review_errors: [],
        repo: repo,
        repo_name: "foo/bar",
        commit_sha: "abc123",
        pull_request_number: 321,
        violations: violations,
        violations_count: violations.size,
      }
      instance_double("Build", default_attributes.merge(attributes))
    end

    def stub_pull_request(comments = [])
      head_commit = instance_double("Commit", file_content: "")
      instance_double("PullRequest", head_commit: head_commit)
    end

    def run_service(build)
      CompleteBuild.call(
        pull_request: stub_pull_request,
        build: build,
        token: "abc123",
      )
    end
  end
end
