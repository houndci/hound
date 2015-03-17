require "spec_helper"

describe Reviewer do
  describe "#run" do
    it "create violations"
    it "comments on GitHub"

    it "create success status to GitHub" do
      repo = create(
        :repo,
        :active,
        github_id: 123,
        full_github_name: "test/repo"
      )
      file = double("File")
      violations = double("Violations")
      build = create(
        :build,
        repo: repo,
        commit_sha: "headsha"
      )
      build_worker = create(:build_worker, build: build)
      reviewer = Reviewer.new(build_worker, file, violations)
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
      violations = double("Violations")
      build = create(:build, repo: repo)
      build_worker = create(:build_worker, build: build)
      reviewer = Reviewer.new(build_worker, file, violations)
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
        violations = double("Violations")
        reviewer = Reviewer.new(build_worker, file, violations)
        stubbed_github_api

        reviewer.run

        expect(build_worker.completed_at).to eq(Time.now)
      end
    end
  end

  def stubbed_github_api
    github_api = double(
      "GithubApi",
      create_success_status: nil
    )
    allow(GithubApi).to receive(:new).and_return(github_api)

    github_api
  end
end
