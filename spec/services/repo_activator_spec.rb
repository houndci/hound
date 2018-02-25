require "rails_helper"

describe RepoActivator do
  describe "#activate" do
    context "when repo is public" do
      context "when repo belongs to an org" do
        it "will not add Hound to repo" do
          repo = create(:repo, private: false, in_organization: true)
          api = stub_github_api
          activator = build_activator(repo: repo)

          activator.activate

          expect(api).not_to have_received(:add_collaborator)
        end

        it "marks repo as active" do
          repo = create(:repo, private: false, in_organization: true)
          stub_github_api
          activator = build_activator(repo: repo)

          activator.activate

          expect(repo.reload).to be_active
        end

        it "returns true" do
          repo = create(:repo, private: false, in_organization: true)
          stub_github_api
          activator = build_activator(repo: repo)

          result = activator.activate

          expect(result).to be_truthy
        end
      end

      context "when repo belongs to a user" do
        it "will not add Hound to repo" do
          repo = create(:repo, private: false, in_organization: false)
          api = stub_github_api
          activator = build_activator(repo: repo)

          activator.activate

          expect(api).not_to have_received(:add_collaborator)
        end

        it "marks repo as active" do
          repo = create(:repo, private: false, in_organization: false)
          stub_github_api
          activator = build_activator(repo: repo)

          activator.activate

          expect(repo.reload).to be_active
        end

        it "returns true" do
          repo = create(:repo, private: false, in_organization: false)
          stub_github_api
          activator = build_activator(repo: repo)

          result = activator.activate

          expect(result).to be_truthy
        end
      end
    end

    context "when repo is private" do
      context "when repo belongs to an org" do
        it "adds Hound to repo" do
          repo = create(:repo, :in_private_org)
          api = stub_github_api
          activator = build_activator(repo: repo)

          activator.activate

          expect(api).to have_received(:add_collaborator).
            with(repo.name, Hound::GITHUB_USERNAME)
          expect(api).to have_received(:accept_invitation).
            with(repo.name)
        end

        it "marks repo as active" do
          repo = create(:repo, :in_private_org)
          github = stub_github_api
          activator = build_activator(repo: repo)

          activator.activate

          expect(repo.reload).to be_active
        end

        it "returns true" do
          repo = create(:repo, :in_private_org)
          stub_github_api
          activator = build_activator(repo: repo)

          result = activator.activate

          expect(result).to be_truthy
        end
      end

      context "when repo belongs to a user" do
        it "adds Hound to repo" do
          repo = create(:repo, private: true, in_organization: false)
          api = stub_github_api
          activator = build_activator(repo: repo)

          activator.activate

          expect(api).to have_received(:add_collaborator)
        end

        it "marks repo as active" do
          repo = create(:repo, private: true, in_organization: false)
          github = stub_github_api
          activator = build_activator(repo: repo)

          activator.activate

          expect(repo.reload).to be_active
        end

        it "returns true" do
          repo = create(:repo, private: true, in_organization: false)
          stub_github_api
          activator = build_activator(repo: repo)

          result = activator.activate

          expect(result).to be_truthy
        end
      end

      context "when repo can be accessed" do
        it "activates the repo without accepting an invitation" do
          repo = create(:repo, private: true)
          activator = build_activator(repo: repo)
          github_api = stub_github_api(
            add_collaborator: true,
            repository?: true,
          )
          allow(github_api).to receive(:accept_invitation).
            and_raise("invitation not found")
          allow(GithubApi).to receive(:new).and_return(github_api)

          result = activator.activate

          expect(result).to eq true
        end
      end
    end

    context "when repo activation succeeds" do
      context "when https is enabled" do
        it "creates GitHub hook using secure build URL" do
          github = stub_github_api
          repo = build(:repo, name: "foo/bar")
          activator = build_activator(repo: repo)

          with_https_enabled do
            activator.activate
          end

          expect(github).to have_received(:create_hook).with(
            repo.name,
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
            repo.name,
            URI.join("http://#{ENV["HOST"]}", "builds").to_s
          )
        end
      end
    end

    context "when adding hound to repo results in an error" do
      it "returns false" do
        repo = build(:repo, private: true)
        activator = build_activator(repo: repo)
        api = stub_github_api
        allow(api).to receive(:add_collaborator).and_raise(Octokit::Error.new)

        result = activator.activate

        expect(result).to be_falsy
      end

      it "adds an error" do
        repo = build(:repo, private: true)
        activator = build_activator(repo: repo)
        error_message = "error"
        api = stub_github_api
        allow(api).to(
          receive(:add_collaborator).and_raise(Octokit::Forbidden.new)
        )
        allow(ErrorMessageTranslation).to receive(:from_error_response).
          and_return(error_message)

        activator.activate

        expect(activator.errors).to match_array([error_message])
      end

      it "reports raised exception to Sentry" do
        repo = build(:repo, private: true)
        activator = build_activator(repo: repo)
        error = Octokit::Error.new
        api = stub_github_api
        allow(api).to receive(:add_collaborator).and_raise(error)
        allow(Raven).to receive(:capture_exception)

        activator.activate

        expect(Raven).to have_received(:capture_exception).with(error)
      end

      it "only swallows Octokit errors" do
        repo = build(:repo, private: true)
        activator = build_activator(repo: repo)
        api = stub_github_api
        allow(api).to receive(:add_collaborator).and_raise(StandardError.new)

        expect { activator.activate }.to raise_error(StandardError)
      end
    end

    context "hook already exists" do
      it "does not raise" do
        repo = build(:repo, private: true)
        activator = build_activator(repo: repo)
        stub_github_api(create_hook: nil)

        expect { activator.activate }.not_to raise_error
      end
    end
  end

  describe "#deactivate" do
    context "when repo is public" do
      it "does not remove Hound from the repo" do
        repo = create(:repo, private: false)
        activator = build_activator(repo: repo)
        api = stub_github_api

        activator.deactivate

        expect(api).not_to have_received(:remove_collaborator)
      end
    end

    context "when repo is private" do
      it "removes Hound from the repo" do
        repo = create(:repo, private: true)
        activator = build_activator(repo: repo)
        api = stub_github_api

        activator.deactivate

        expect(api).to have_received(:remove_collaborator).
          with(repo.name, Hound::GITHUB_USERNAME)
      end

      context "when the subscribed user does not have a membership" do
        it "deactivates the repo" do
          user = create(:user)
          repo = create(:repo, :active, private: true)
          create(:subscription, user: user, repo: repo)
          activator = build_activator(repo: repo)

          activator.deactivate

          expect(repo.reload).not_to be_active
        end

        it "does not interact with GitHub" do
          user = create(:user)
          repo = create(:repo, :active, private: true)
          create(:subscription, user: user, repo: repo)
          activator = build_activator(repo: repo)
          api = stub_github_api

          activator.deactivate

          expect(api).not_to have_received(:remove_collaborator)
          expect(api).not_to have_received(:remove_hook)
        end
      end
    end

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
        repo = build(:repo, private: true)
        activator = build_activator(repo: repo)
        api = stub_github_api
        allow(api).to receive(:remove_collaborator).and_return(false)

        result = activator.deactivate

        expect(result).to be true
      end
    end
  end

  def build_activator(token: "githubtoken", repo: build(:repo))
    RepoActivator.new(github_token: token, repo: repo)
  end

  def stub_github_api(options = {})
    default_options = {
      remove_hook: true,
      add_collaborator: nil,
      remove_collaborator: true,
      accept_invitation: true,
      repository?: false,
    }
    api = instance_double("GithubApi", default_options.merge(options))
    hook = double(:hook, id: 1)
    allow(api).to receive(:create_hook).and_yield(hook)
    allow(GithubApi).to receive(:new).and_return(api)
    api
  end
end
