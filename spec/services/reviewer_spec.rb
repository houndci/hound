require "spec_helper"

describe Reviewer do
  describe "#run" do
    context "violations" do
      context "when violations_attrs present" do
        it "creates violations using violations_attrs" do
          build = create(:build)
          build_worker = create(:build_worker, build: build)
          reviewer = Reviewer.new(build_worker, file, violations_attrs)
          stubbed_github_api

          reviewer.run

          first_violation = Violation.first
          expect(first_violation.filename).to eq("a.a")
          expect(first_violation.line_number).to eq(0)
          expect(first_violation.messages).to eq(["I have an error"])
          expect(first_violation.build).to eq(Build.last)
          expect(first_violation.patch_position).to eq(0)
        end
      end

      context "when violations_attrs not present" do
        it "does not create violations" do
          build = create(:build)
          build_worker = create(:build_worker, build: build)
          reviewer = Reviewer.new(build_worker, file, [])
          stubbed_github_api

          reviewer.run

          expect(Violation.count).to eq(0)
        end
      end
    end

    context "comments" do
      context "when there are no violations" do
        it "sends no comments" do
          github_api = stubbed_github_api
          build = create(:build, commit_sha: "sha")
          build_worker = create(:build_worker, build: build)
          reviewer = Reviewer.new(build_worker, file, [])

          reviewer.run

          expect(github_api).not_to have_received(:pull_request_comments)
          expect(github_api).not_to have_received(:add_pull_request_comment)
        end
      end

      context "when there are violations" do
        it "comments on violations" do
          commenter = stubbed_commenter
          stubbed_github_api
          build = create(:build)
          build_worker = create(:build_worker, build: build)
          reviewer = Reviewer.new(build_worker, file, violations_attrs)

          reviewer.run

          expect(commenter).to have_received(:comment_on_violations).
            with(Violation.all)
        end

        it "comments a maximum number of times" do
          allow(ENV).to receive(:[]).with("HOUND_GITHUB_TOKEN").
            and_return("something")
          stub_const("::BuildRunner::MAX_COMMENTS", 1)
          commenter = stubbed_commenter
          stubbed_github_api
          build = create(:build)
          build_worker = create(:build_worker, build: build)
          reviewer = Reviewer.new(build_worker, file, violations_attrs)

          reviewer.run

          expect(commenter).to have_received(:comment_on_violations).
            with(Violation.all.take(BuildRunner::MAX_COMMENTS))
        end

        it "hits the github_api with review payload" do
          github_api = stubbed_github_api
          build = create(:build, commit_sha: "sha")
          repo = build.repo
          build_worker = create(:build_worker, build: build)
          commit = double("Commit")
          allow(Commit).to receive(:new).and_return(commit)
          reviewer = Reviewer.new(build_worker, file, violations_attrs)

          reviewer.run

          expect(github_api).to have_received(:pull_request_comments).with(
            repo.full_github_name,
            build.pull_request_number
          )
          expect(github_api).to have_received(:add_pull_request_comment).with(
            pull_request_number: build.pull_request_number,
            comment: "I have an error",
            commit: commit,
            filename: "a.a",
            patch_position: 0
          )
          expect(Commit).to have_received(:new).with(
            repo.full_github_name,
            "sha",
            github_api
          )
        end
      end
    end

    it "create success status to GitHub" do
      repo = create(
        :repo,
        :active,
        github_id: 123,
        full_github_name: "test/repo"
      )
      file = double("File")
      violations_attrs = []
      build = create(
        :build,
        repo: repo,
        commit_sha: "headsha"
      )
      build_worker = create(:build_worker, build: build)
      reviewer = Reviewer.new(build_worker, file, violations_attrs)
      github_api = stubbed_github_api

      reviewer.run

      expect(github_api).to have_received(:create_success_status).with(
        "test/repo",
        "headsha",
        "Hound has reviewed all the changes!"
      )
    end

    it "tracks build complete to analytics" do
      repo = create(:repo, :active, github_id: 123, private: true)
      create(:subscription, repo: repo)
      file = double("File")
      violations_attrs = []
      build = create(:build, repo: repo)
      build_worker = create(:build_worker, build: build)
      reviewer = Reviewer.new(build_worker, file, violations_attrs)
      stubbed_github_api

      reviewer.run

      expect(analytics).to have_tracked("Build Completed").
        for_user(repo.subscription.user).
        with(properties: { name: repo.full_github_name, private: true })
    end

    it "mark build worker as complete" do
      travel_to(Time.now) do
        build_worker = create(:build_worker)
        file = double("File")
        violations_attrs = []
        reviewer = Reviewer.new(build_worker, file, violations_attrs)
        stubbed_github_api

        reviewer.run

        expect(build_worker.completed_at).to eq(Time.now)
      end
    end
  end

  def stubbed_github_api
    github_api = double(
      "GithubApi",
      create_success_status: nil,
      pull_request_comments: [],
      add_pull_request_comment: nil
    )
    allow(GithubApi).to receive(:new).and_return(github_api)

    github_api
  end

  def stubbed_commenter
    commenter = double(:commenter).as_null_object
    allow(Commenter).to receive(:new).and_return(commenter)

    commenter
  end

  def violations_attrs
    [
      {
        line_number: 0,
        messages: ["I have an error"],
      }
    ]
  end

  def content
    "def good; end"
  end

  def file
    {
      filename: "a.a",
      patch: "+#{content}",
      content: content
    }
  end
end
