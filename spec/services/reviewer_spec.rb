require "spec_helper"

describe Reviewer do
  describe "#run" do
    context "violations" do
      context "when violations_attrs present" do
        it "creates violations using violations_attrs" do
          content = "def good; end"
          build = create(:build)
          violations_attrs = [
            {
              line_number: 0,
              messages: ["I have an error"],
            },
            {
              line_number: 0,
              messages: ["I have an error"],
            }
          ]

          file = {
            filename: "a.a",
            patch: "+#{content}",
            content: content
          }

          build_worker = create(:build_worker, build: build)
          reviewer = Reviewer.new(build_worker, file, violations_attrs)
          stubbed_github_api

          reviewer.run

          expect(Violation.count).to eq(2)

          first_violation = Violation.first
          expect(first_violation.filename).to eq("a.a")
          expect(first_violation.line_number).to eq(0)
          expect(first_violation.messages).to eq(["I have an error"])
          expect(first_violation.build_id).to eq(build.id)
          expect(first_violation.patch_position).to eq(0)

          second_violation = Violation.last
          expect(second_violation.filename).to eq("a.a")
          expect(second_violation.line_number).to eq(0)
          expect(second_violation.messages).to eq(["I have an error"])
          expect(second_violation.build_id).to eq(build.id)
          expect(first_violation.patch_position).to eq(0)
        end
      end

      context "when violations_attrs not present"
    end

    it "comments on GitHub"

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
      create_success_status: nil
    )
    allow(GithubApi).to receive(:new).and_return(github_api)

    github_api
  end
end
