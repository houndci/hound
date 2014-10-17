require 'spec_helper'

describe RepoActivator do
  describe "#enable" do
    context "when success" do
      it "enables repo" do
        token = "githubtoken"
        repo = create(:repo)
        stub_github_api
        allow(JobQueue).to receive(:push).and_return(true)
        activator = RepoActivator.new(github_token: token, repo: repo)

        result = activator.enable

        expect(result).to be_truthy
        expect(GithubApi).to have_received(:new).with(token)
        expect(repo.reload).to be_enabled
      end

      it "makes Hound a collaborator" do
        repo = create(:repo)
        github = stub_github_api
        token = "githubtoken"
        allow(JobQueue).to receive(:push)
        activator = RepoActivator.new(github_token: token, repo: repo)

        activator.enable

        expect(github).to have_received(:add_user_to_repo)
      end

      it "returns true if the repo enables successfully" do
        repo = create(:repo)
        stub_github_api
        token = "githubtoken"
        allow(JobQueue).to receive(:push).and_return(true)
        activator = RepoActivator.new(github_token: token, repo: repo)

        result = activator.enable

        expect(result).to be_truthy
      end

      context "when https is enabled" do
        it "creates GitHub hook using secure build URL" do
          with_https_enabled do
            repo = create(:repo)
            token = "githubtoken"
            github = stub_github_api
            allow(JobQueue).to receive(:push)
            activator = RepoActivator.new(github_token: token, repo: repo)

            activator.enable

            expect(github).to have_received(:create_hook).with(
              repo.full_github_name,
              URI.join("https://#{ENV['HOST']}", 'builds').to_s
            )
          end
        end
      end

      context "when https is disabled" do
        it "creates GitHub hook using insecure build URL" do
          repo = create(:repo)
          github = stub_github_api
          token = "githubtoken"
          allow(JobQueue).to receive(:push)
          activator = RepoActivator.new(github_token: token, repo: repo)

          activator.enable

          expect(github).to have_received(:create_hook).with(
            repo.full_github_name,
            URI.join("http://#{ENV['HOST']}", 'builds').to_s
          )
        end
      end
    end

    context "when API request errors" do
      it "returns false" do
        token = nil
        repo = build_stubbed(:repo)
        allow(JobQueue).to receive(:push)
        expect(GithubApi).to receive(:new).and_raise(Octokit::Error.new)
        activator = RepoActivator.new(github_token: token, repo: repo)

        result = activator.enable

        expect(result).to be_falsy
      end

      it "only swallows Octokit errors" do
        token = "githubtoken"
        repo = double("repo")
        allow(JobQueue).to receive(:push)
        allow(GithubApi).to receive(:new).and_raise(Exception.new)
        activator = RepoActivator.new(github_token: token, repo: repo)

        expect { activator.enable }.to raise_error(Exception)
      end

      context "when Hound cannot be added to repo" do
        it "returns false" do
          token = "githubtoken"
          repo = build_stubbed(:repo, full_github_name: "test/repo")
          github = double(:github, add_user_to_repo: false)
          allow(JobQueue).to receive(:push)
          allow(GithubApi).to receive(:new).and_return(github)
          activator = RepoActivator.new(github_token: token, repo: repo)

          result = activator.enable

          expect(result).to be_falsy
        end
      end
    end

    context "hook already exists" do
      it "does not raise" do
        token = "token"
        repo = build_stubbed(:repo)
        allow(JobQueue).to receive(:push)
        github = double(:github, create_hook: nil, add_user_to_repo: true)
        allow(GithubApi).to receive(:new).and_return(github)
        activator = RepoActivator.new(github_token: token, repo: repo)

        expect { activator.enable }.not_to raise_error
        expect(GithubApi).to have_received(:new).with(token)
      end
    end
  end

  describe "#disable" do
    context "when repo activation succeeds" do
      it "disables repo" do
        stub_github_api
        token = "githubtoken"
        repo = create(:repo)
        allow(JobQueue).to receive(:push)
        create(:membership, repo: repo)
        activator = RepoActivator.new(github_token: token, repo: repo)

        activator.disable

        expect(GithubApi).to have_received(:new).with(token)
        expect(repo).not_to be_enabled
      end

      it "removes GitHub hook" do
        github_api = stub_github_api
        token = "githubtoken"
        allow(JobQueue).to receive(:push)
        repo = create(:repo)
        create(:membership, repo: repo)
        activator = RepoActivator.new(github_token: token, repo: repo)

        activator.disable

        expect(github_api).to have_received(:remove_hook)
        expect(repo.hook_id).to be_nil
      end

      it "returns true if the repo enables successfully" do
        stub_github_api
        token = "githubtoken"
        allow(JobQueue).to receive(:push)
        membership = create(:membership)
        repo = membership.repo
        activator = RepoActivator.new(github_token: token, repo: repo)

        result = activator.disable

        expect(result).to be_truthy
      end
    end

    context "when repo activation succeeds" do
      it "returns false if the repo does not enable successfully" do
        repo = double('repo')
        token = nil
        allow(JobQueue).to receive(:push)
        expect(GithubApi).to receive(:new).and_raise(Octokit::Error.new)
        activator = RepoActivator.new(github_token: token, repo: repo)

        result = activator.disable

        expect(result).to be_falsy
      end

      it "only swallows Octokit errors" do
        repo = double('repo')
        token = nil
        allow(JobQueue).to receive(:push)
        expect(GithubApi).to receive(:new).and_raise(Exception.new)
        activator = RepoActivator.new(github_token: token, repo: repo)

        expect { activator.disable }.to raise_error(Exception)
      end
    end
  end

  def stub_github_api
    hook = double(:hook, id: 1)
    api = double(:github_api, add_user_to_repo: true, remove_hook: true)
    allow(api).to receive(:create_hook).and_yield(hook)
    allow(GithubApi).to receive(:new).and_return(api)
    api
  end
end
