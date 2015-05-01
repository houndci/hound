require "rails_helper"

describe BuildReport do
  describe ".run" do
    context "when build has violations" do
      it "comments a maximum number of times" do
        stub_const("::BuildReport::MAX_COMMENTS", 1)
        commenter = stubbed_commenter(comment_on_violations: true)
        build = create(:build, violations: build_list(:violation, 2))
        stubbed_github_api
        pull_request = stubbed_pull_request

        BuildReport.run(pull_request, build)

        expect(commenter).to have_received(:comment_on_violations).
          with(build.violations.take(BuildReport::MAX_COMMENTS))
      end

      it "creates GitHub statuses" do
        repo = create(:repo, full_github_name: "test/repo")
        build = create(
          :build,
          commit_sha: "headsha",
          repo: repo,
          violations: [
            build(:violation, messages: ["wrong", "bad"]),
          ],
        )
        stubbed_commenter
        github_api = stubbed_github_api
        pull_request = stubbed_pull_request

        BuildReport.run(pull_request, build)

        expect(github_api).to have_received(:create_success_status).with(
          "test/repo",
          "headsha",
          "2 violations found."
        )
      end
    end

    context "with subscribed private repo and opened pull request" do
      it "tracks build events" do
        repo = create(:repo, :active, github_id: 123, private: true)
        build = create(:build, repo: repo)
        create(:subscription, repo: repo)
        stubbed_commenter
        stubbed_github_api
        pull_request = stubbed_pull_request

        BuildReport.run(pull_request, build)

        expect(analytics).to have_tracked("Build Completed").
          for_user(repo.subscription.user).
          with(properties: { name: repo.full_github_name, private: true })
      end
    end

    def stubbed_commenter(options = {})
      commenter = double(:commenter, options).as_null_object
      allow(Commenter).to receive(:new).and_return(commenter)

      commenter
    end

    def stubbed_pull_request
      head_commit = double(
        "HeadCommit",
        sha: "headsha",
        repo_name: "test/repo",
      )
      pull_request = double(
        :pull_request,
        pull_request_files: [double(:file)],
        config: double(:config),
        opened?: true,
        head_commit: head_commit,
      )
      allow(PullRequest).to receive(:new).and_return(pull_request)

      pull_request
    end

    def stubbed_github_api
      github_api = double(
        "GithubApi",
        create_pending_status: nil,
        create_success_status: nil,
        create_error_status: nil
      )
      allow(GithubApi).to receive(:new).and_return(github_api)

      github_api
    end
  end
end
