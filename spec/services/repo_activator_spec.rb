require "rails_helper"

describe RepoActivator do
  describe "#activate" do
    context "with org repo" do
      it "will enqueue org invitation job" do
        allow(AcceptOrgInvitationsJob).to receive(:perform_later)
        repo = create(:repo, in_organization: true)
        stub_github_api
        activator = build_activator(repo: repo)

        activator.activate

        expect(AcceptOrgInvitationsJob).to have_received(:perform_later)
      end

      it "marks repo as active" do
        repo = create(:repo, in_organization: true)
        github = stub_github_api
        allow(github).to receive(:accept_pending_invitations)
        activator = build_activator(repo: repo)

        result = activator.activate

        expect(result).to be_truthy
        expect(repo.reload).to be_active
      end
    end

    context "without org repo" do
      it "will not enqueue org invitation job" do
        allow(AcceptOrgInvitationsJob).to receive(:perform_later)
        repo = create(:repo)
        stub_github_api
        activator = build_activator(repo: repo)

        activator.activate

        expect(repo.in_organization).to be_falsy
        expect(AcceptOrgInvitationsJob).not_to have_received(:perform_later)
      end

      it "marks repo as active" do
        repo = create(:repo, in_organization: false)
        stub_github_api
        activator = build_activator(repo: repo)

        result = activator.activate

        expect(result).to be_truthy
        expect(repo.reload).to be_active
      end
    end

    context "when repo activation succeeds" do
      it "adds Hound to the repo" do
        token = "some_token"
        repo = build(:repo, name: "foo/bar")
        github = stub_github_api
        activator = build_activator(repo: repo, token: token)

        activator.activate

        expect(GithubApi).to have_received(:new).with(token)
        expect(AddHoundToRepo).to have_received(:run).with(repo.name, github)
      end

      context "when https is enabled" do
        it "creates GitHub hook using secure build URL" do
          github = stub_github_api
          repo = build(:repo, name: "foo/bar")
          activator = build_activator(repo: repo)

          with_https_enabled do
            activator.activate
          end

          expect(github).to have_received(:create_hook).with(
            repo.full_github_name,
            URI.join("https://#{ENV["HOST"]}", "builds").to_s
          )
        end
      end

      context "when https is disabled" do
        it "creates GitHub hook using insecure build URL" do
          github = stub_github_api
          repo = build(:repo)
          activator = build_activator(repo: repo)

          activator.activate

          expect(github).to have_received(:create_hook).with(
            repo.full_github_name,
            URI.join("http://#{ENV["HOST"]}", "builds").to_s
          )
        end
      end
    end

    context "when adding hound to repo results in an error" do
      it "returns false" do
        activator = build_activator
        allow(AddHoundToRepo).to receive(:run).and_raise(Octokit::Error.new)

        result = activator.activate

        expect(result).to be_falsy
      end

      it "adds an error" do
        activator = build_activator
        error_message = "error"
        allow(AddHoundToRepo).to receive(:run).and_raise(Octokit::Forbidden.new)
        allow(ErrorMessageTranslation).to receive(:from_error_response).
          and_return(error_message)

        activator.activate

        expect(activator.errors).to match_array([error_message])
      end

      it "reports raised exception to Sentry" do
        activator = build_activator
        error = Octokit::Error.new
        allow(AddHoundToRepo).to receive(:run).and_raise(error)
        allow(Raven).to receive(:capture_exception)

        activator.activate

        expect(Raven).to have_received(:capture_exception).with(error)
      end

      it "only swallows Octokit errors" do
        activator = build_activator
        allow(AddHoundToRepo).to receive(:run).and_raise(StandardError.new)

        expect { activator.activate }.to raise_error(StandardError)
      end
    end

    context "hook already exists" do
      it "does not raise" do
        activator = build_activator
        github = double("GithubApi", create_hook: nil)
        allow(GithubApi).to receive(:new).and_return(github)

        expect { activator.activate }.not_to raise_error
      end
    end
  end

  describe "#deactivate" do
    context "when repo deactivation succeeds" do
      it "marks repo as deactivated" do
        repo = create(:repo)
        activator = build_activator(repo: repo)
        stub_github_api

        activator.deactivate

        expect(repo.reload).not_to be_active
      end

      it "removes GitHub hook" do
        repo = create(:repo)
        activator = build_activator(repo: repo)
        github_api = stub_github_api

        activator.deactivate

        expect(github_api).to have_received(:remove_hook)
        expect(repo.hook_id).to be_nil
      end

      it "removes hound from repo" do
        repo = create(:repo)
        activator = build_activator(repo: repo)
        github_api = stub_github_api

        activator.deactivate

        expect(RemoveHoundFromRepo).to have_received(:run).
          with(repo.full_github_name, github_api)
      end

      it "returns true" do
        activator = build_activator
        stub_github_api

        result = activator.deactivate

        expect(result).to be true
      end
    end

    context "when repo deactivation fails" do
      it "returns false" do
        activator = build_activator
        allow(GithubApi).to receive(:new).and_raise(Octokit::Error.new)

        result = activator.deactivate

        expect(result).to be false
      end

      it "only swallows Octokit errors" do
        error = StandardError.new("this should bubble through")
        activator = build_activator
        expect(GithubApi).to receive(:new).and_raise(error)

        expect { activator.deactivate }.to raise_error(error)
      end
    end

    context "when removing houndci user from org fails" do
      it "returns true" do
        activator = build_activator
        stub_github_api
        allow(RemoveHoundFromRepo).to receive(:run).and_return(false)

        result = activator.deactivate

        expect(result).to be true
      end
    end
  end

  def build_activator(token: "githubtoken", repo: build(:repo))
    allow(RemoveHoundFromRepo).to receive(:run)
    allow(AddHoundToRepo).to receive(:run).and_return(true)

    RepoActivator.new(github_token: token, repo: repo)
  end

  def stub_github_api
    hook = double(:hook, id: 1)
    api = double(:github_api, remove_hook: true)
    allow(api).to receive(:create_hook).and_yield(hook)
    allow(GithubApi).to receive(:new).and_return(api)
    api
  end
end
