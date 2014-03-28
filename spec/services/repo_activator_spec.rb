require 'spec_helper'

describe RepoActivator do
  describe '#activate' do
    context 'when repo activation succeeds' do
      it 'activates repo' do
        github_token = 'githubtoken'
        repo = create(:repo)
        stub_github_api
        activator = RepoActivator.new

        activator.activate(repo, github_token)

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

            expect(github).to have_received(:create_pull_request_hook).with(
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

          expect(github).to have_received(:create_pull_request_hook).with(
            repo.full_github_name,
            URI.join("http://#{ENV['HOST']}", 'builds').to_s
          )
        end
      end
    end

    context 'when repo activation fails' do
      it 'returns false if the repo does not activate successfully' do
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

        expect(github_api).to have_received(:remove_pull_request_hook)
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
    api = double(:github_api, create_pull_request_hook: hook).as_null_object
    GithubApi.stub(new: api)
    api
  end
end
