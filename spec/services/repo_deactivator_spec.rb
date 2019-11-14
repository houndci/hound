require "rails_helper"

RSpec.describe DeactivateRepo do
  describe "#call" do
    context "when repo is public" do
      it "does not remove Hound from the repo" do
        repo = create(:repo, private: false)
        service = build_service(repo: repo)
        api = stub_github_api

        service.call

        expect(api).not_to have_received(:remove_collaborator)
      end
    end

    context "when repo is private" do
      it "removes Hound from the repo" do
        repo = create(:repo, private: true)
        service = build_service(repo: repo)
        api = stub_github_api

        service.call

        expect(api).to have_received(:remove_collaborator).
          with(repo.name, Hound::GITHUB_USERNAME)
      end

      context "when the subscribed user does not have a membership" do
        it "deactivates the repo" do
          user = create(:user)
          repo = create(:repo, :active, private: true)
          create(:subscription, user: user, repo: repo)
          service = build_service(repo: repo)

          service.call

          expect(repo.reload).not_to be_active
        end

        it "does not interact with GitHub" do
          user = create(:user)
          repo = create(:repo, :active, private: true)
          create(:subscription, user: user, repo: repo)
          service = build_service(repo: repo)
          api = stub_github_api

          service.call

          expect(api).not_to have_received(:remove_collaborator)
          expect(api).not_to have_received(:remove_hook)
        end
      end
    end

    context "when repo deactivation succeeds" do
      it "marks repo as deactivated" do
        repo = create(:repo)
        service = build_service(repo: repo)
        stub_github_api

        service.call

        expect(repo.reload).not_to be_active
      end

      it "removes GitHub hook" do
        repo = create(:repo)
        service = build_service(repo: repo)
        github_api = stub_github_api

        service.call

        expect(github_api).to have_received(:remove_hook)
        expect(repo.hook_id).to be_nil
      end

      it "returns true" do
        service = build_service
        stub_github_api

        result = service.call

        expect(result).to be true
      end
    end

    context "when repo deactivation fails" do
      it "returns false" do
        service = build_service
        allow(GitHubApi).to receive(:new).and_raise(Octokit::Error.new)

        result = service.call

        expect(result).to be false
      end

      it "only swallows Octokit errors" do
        error = StandardError.new("this should bubble through")
        service = build_service
        expect(GitHubApi).to receive(:new).and_raise(error)

        expect { service.call }.to raise_error(error)
      end
    end

    context "when removing houndci user from org fails" do
      it "returns true" do
        repo = build(:repo, private: true)
        service = build_service(repo: repo)
        api = stub_github_api
        allow(api).to receive(:remove_collaborator).and_return(false)

        result = service.call

        expect(result).to be true
      end
    end
  end

  def build_service(token: "githubtoken", repo: build(:repo))
    DeactivateRepo.new(github_token: token, repo: repo)
  end

  def stub_github_api(options = {})
    default_options = {
      repository?: true,
      remove_hook: true,
      remove_collaborator: true,
    }
    api = instance_double("GitHubApi", default_options.merge(options))
    allow(GitHubApi).to receive(:new).and_return(api)
    api
  end
end
