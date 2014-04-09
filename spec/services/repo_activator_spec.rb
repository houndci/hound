require 'spec_helper'

describe RepoActivator do
  describe '#activate' do
    context 'when repo activation succeeds' do
      it 'activates repo' do
        github_token = 'githubtoken'
        repo = create(:repo)
        stub_github_api
        activator = RepoActivator.new

        expect(activator.activate(repo, github_token)).to be_true
        expect(GithubApi).to have_received(:new).with(github_token)
        expect(repo.reload).to be_active
      end

      it 'makes Hound a collaborator' do
        repo = create(:repo)
        github = stub_github_api
        activator = RepoActivator.new

        activator.activate(repo, 'githubtoken')

        expect(github).to have_received(:add_user_to_repo)
      end

      it 'returns true if the repo activates successfully' do
        repo = create(:repo)
        stub_github_api
        activator = RepoActivator.new

        response = activator.activate(repo, 'githubtoken')

        expect(response).to be_true
      end

      context 'when https is enabled' do
        it 'creates GitHub hook using secure build URL' do
          with_https_enabled do
            repo = create(:repo)
            github = stub_github_api
            activator = RepoActivator.new

            activator.activate(repo, 'githubtoken')

            expect(github).to have_received(:create_hook).with(
              repo.full_github_name,
              URI.join("https://#{ENV['HOST']}", 'builds').to_s
            )
          end
        end
      end

      context 'when https is disabled' do
        it 'creates GitHub hook using insecure build URL' do
          repo = create(:repo)
          github = stub_github_api
          activator = RepoActivator.new

          activator.activate(repo, 'githubtoken')

          expect(github).to have_received(:create_hook).with(
            repo.full_github_name,
            URI.join("http://#{ENV['HOST']}", 'builds').to_s
          )
        end
      end
    end

    context 'when repo activation fails' do
      it 'returns false if API request raises' do
        github_token = nil
        repo = double('repo')
        expect(GithubApi).to receive(:new).and_raise(Octokit::Error.new)
        activator = RepoActivator.new

        response = activator.activate(repo, github_token)

        expect(response).to be_false
      end

      it 'only swallows Octokit errors' do
        github_token = 'githubtoken'
        repo = double('repo')
        expect(GithubApi).to receive(:new).and_raise(Exception.new)
        activator = RepoActivator.new

        expect { activator.activate(repo, github_token) }.to raise_error(Exception)
      end

      context 'when Hound cannot be added to repo' do
        it 'returns false' do
          repo = double(:repo, full_github_name: 'test/repo')
          token = 'githubtoken'
          github = double(:github, add_user_to_repo: false)
          GithubApi.stub(new: github)
          activator = RepoActivator.new

          expect(activator.activate(repo, github)).to be_false
        end
      end
    end

    context 'hook already exists' do
      it 'does not raise' do
        token = 'token'
        repo = create(:repo)
        github = double(
          :github,
          create_hook: nil,
          add_user_to_repo: true
        )
        GithubApi.stub(new: github)
        activator = RepoActivator.new

        expect { activator.activate(repo, token) }.not_to raise_error

        expect(GithubApi).to have_received(:new).with(token)
      end
    end
  end

  describe '#deactivate' do
    context 'when repo activation succeeds' do
      it 'deactivates repo' do
        stub_github_api
        github_token = 'githubtoken'
        repo = create(:repo)
        create(:membership, repo: repo)
        activator = RepoActivator.new

        activator.deactivate(repo, github_token)

        expect(GithubApi).to have_received(:new).with(github_token)
        expect(repo.active?).to be_false
      end

      it 'removes GitHub hook' do
        github_api = stub_github_api
        repo = create(:repo)
        create(:membership, repo: repo)
        activator = RepoActivator.new

        activator.deactivate(repo, 'githubtoken')

        expect(github_api).to have_received(:remove_hook)
        expect(repo.hook_id).to be_nil
      end

      it 'returns true if the repo activates successfully' do
        github_api = stub_github_api
        repo = create(:repo)
        create(:membership, repo: repo)
        activator = RepoActivator.new

        response = activator.deactivate(repo, 'githubtoken')

        expect(response).to be_true
      end
    end

    context 'when repo activation succeeds' do
      it 'returns false if the repo does not activate successfully' do
        repo = double('repo')
        github_token = nil
        expect(GithubApi).to receive(:new).and_raise(Octokit::Error.new)
        activator = RepoActivator.new

        response = activator.deactivate(repo, github_token)

        expect(response).to be_false
      end

      it 'only swallows Octokit errors' do
        repo = double('repo')
        github_token = nil
        expect(GithubApi).to receive(:new).and_raise(Exception.new)
        activator = RepoActivator.new

        expect { activator.deactivate(repo, github_token) }.to raise_error(Exception)
      end
    end
  end

  def stub_github_api
    hook = double(:hook, id: 1)
    api = double(:github_api, add_user_to_repo: true, remove_hook: true)
    api.stub(:create_hook).and_yield(hook)
    GithubApi.stub(new: api)
    api
  end
end
