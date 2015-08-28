require "rails_helper"

describe BuildReport do
  describe ".run" do
    context "when build has violations" do
      context "when the build is complete" do
        it "comments a maximum number of times" do
          stub_const("Hound::MAX_COMMENTS", 1)
          commenter = stubbed_commenter(comment_on_violations: true)
          file_review = create(
            :file_review,
            :completed,
            violations: build_list(:violation, 2),
          )
          stubbed_github_api

          run_service(file_review.build)

          expect(commenter).to have_received(:comment_on_violations) do |arg|
            expect(arg.size).to eq 1
            expect(arg.first).to be_a Violation
          end
        end

        context "when fail on violations is disabled" do
          it "sets GitHub status to complete" do
            file_review = create(
              :file_review,
              completed_at: Time.current,
              violations: [build(:violation)],
            )
            stubbed_commenter
            stubbed_repo_config(fail_on_violations?: false)
            github_api = stubbed_github_api

            run_service(file_review.build)

            expect(github_api).to have_received(:create_success_status).with(
              file_review.build.repo_name,
              file_review.build.commit_sha,
              "1 violation found.",
            )
          end
        end

        context "when fail on violations is enabled" do
          it "sets GitHub status to failed" do
            file_review = create(
              :file_review,
              completed_at: Time.current,
              violations: [build(:violation)],
            )
            stubbed_commenter
            stubbed_repo_config(fail_on_violations?: true)
            github_api = stubbed_github_api

            run_service(file_review.build)

            expect(github_api).to have_received(:create_error_status).with(
              file_review.build.repo_name,
              file_review.build.commit_sha,
              "1 violation found.",
            )
          end
        end
      end

      context "when the build is not complete" do
        it "does not comment" do
          commenter = stubbed_commenter(comment_on_violations: true)
          file_review = create(
            :file_review,
            violations: build_list(:violation, 2),
            completed_at: nil,
          )
          stubbed_github_api

          run_service(file_review.build)

          expect(commenter).not_to have_received(:comment_on_violations)
        end

        it "does not set GitHub status to compelte" do
          file_review = create(
            :file_review,
            completed_at: nil,
            violations: [build(:violation)],
          )
          stubbed_commenter
          github_api = stubbed_github_api

          run_service(file_review.build)

          expect(github_api).not_to have_received(:create_success_status)
        end
      end
    end

    context "when build does not have violations" do
      it "sets GitHub status to complete" do
        file_review = create(
          :file_review,
          completed_at: Time.current,
          violations: [],
        )
        stubbed_commenter
        stubbed_repo_config(fail_on_violations?: false)
        github_api = stubbed_github_api

        run_service(file_review.build)

        expect(github_api).to have_received(:create_success_status).with(
          file_review.build.repo_name,
          file_review.build.commit_sha,
          I18n.t(:complete_status, count: 0),
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

        run_service(build)

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

    def stubbed_github_api
      github_api = double(
        "GithubApi",
        create_success_status: nil,
        create_error_status: nil,
      )
      allow(GithubApi).to receive(:new).and_return(github_api)

      github_api
    end

    def stubbed_repo_config(options = {})
      repo_config = double("RepoConfig", options)
      allow(RepoConfig).to receive(:new).and_return(repo_config)

      repo_config
    end

    def run_service(build)
      head_commit = double("Commit", file_content: "")
      pull_request = double("PullRequest", head_commit: head_commit)
      BuildReport.run(pull_request: pull_request, build: build, token: "abc123")
    end
  end
end
