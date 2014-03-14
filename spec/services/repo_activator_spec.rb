require 'spec_helper'

describe RepoActivator do
  describe '#activate' do
    context 'when repo activation succeeds' do
      it 'activates repo' do
        user = build(:user)
        repo = create(:repo)
        hook = double(id: 'hookid')
        github = double(
          :github_api,
          create_pull_request_hook: hook
        ).as_null_object
        GithubApi.stub(:new).with(user.github_token).and_return(github)
        activator = RepoActivator.new

        activator.activate(repo, user)

        expect(repo.reload).to be_active
      end

      it 'creates GitHub hook' do
        user = build(:user)
        repo = create(:repo)
        hook = double(id: 'hookid')
        github = double(
          :github_api,
          create_pull_request_hook: hook
        ).as_null_object
        GithubApi.stub(new: github)
        activator = RepoActivator.new

        activator.activate(repo, user)

        expect(GithubApi).to have_received(:new).with(user.github_token)
        expect(github).to have_received(:create_pull_request_hook).with(
          repo.full_github_name,
          URI.join("http://#{ENV['HOST']}", 'builds').to_s
        )
      end

      it 'makes Hound a collaborator' do
        user = build(:user)
        repo = create(:repo)
        hook = double(id: 'hookid')
        github = double(
          :github_api,
          create_pull_request_hook: hook,
          add_hound_to_repo: true
        )
        GithubApi.stub(new: github)
        activator = RepoActivator.new

        activator.activate(repo, user)

        expect(GithubApi).to have_received(:new).with(user.github_token)
        expect(github).to have_received(:add_hound_to_repo)
      end

      it 'returns true if the repo activates successfully' do
        user = build(:user)
        repo = create(:repo)
        hook = double(id: 'hookid')
        github = double(
          :github_api,
          create_pull_request_hook: hook
        ).as_null_object
        GithubApi.stub(new: github)
        activator = RepoActivator.new

        response = activator.activate(repo, user)

        expect(response).to be_true
      end
    end

    context 'when repo activation fails' do
      it 'returns false if the repo does not activate successfully' do
        user = double('user', github_token: nil)
        repo = double('repo')
        expect(GithubApi).to receive(:new).and_raise(Octokit::Error.new)
        activator = RepoActivator.new

        response = activator.activate(repo, user)

        expect(response).to be_false
      end

      it 'only swallows Octokit errors' do
        user = double('user', github_token: nil)
        repo = double('repo')
        expect(GithubApi).to receive(:new).and_raise(Exception.new)
        activator = RepoActivator.new

        expect { activator.activate(repo, user) }.to raise_error(Exception)
      end
    end
  end

  describe '#deactivate' do
    context 'when repo activation succeeds' do
      it 'deactivates repo' do
        stub_github_api
        repo = create(:repo)
        create(:membership, repo: repo)
        activator = RepoActivator.new

        activator.deactivate(repo)

        expect(repo.active?).to be_false
      end

      it 'removes GitHub hook' do
        github_api = stub_github_api
        repo = create(:repo)
        create(:membership, repo: repo)
        activator = RepoActivator.new

        activator.deactivate(repo)

        expect(github_api).to have_received(:remove_pull_request_hook)
        expect(repo.hook_id).to be_nil
      end

      it 'returns true if the repo activates successfully' do
        github_api = stub_github_api
        repo = create(:repo)
        create(:membership, repo: repo)
        activator = RepoActivator.new

        response = activator.deactivate(repo)

        expect(response).to be_true
      end
    end

    context 'when repo activation succeeds' do
      it 'returns false if the repo does not activate successfully' do
        repo = double('repo', github_token: nil)
        expect(GithubApi).to receive(:new).and_raise(Octokit::Error.new)
        activator = RepoActivator.new

        response = activator.deactivate(repo)

        expect(response).to be_false
      end

      it 'only swallows Octokit errors' do
        repo = double('repo', github_token: nil)
        expect(GithubApi).to receive(:new).and_raise(Exception.new)
        activator = RepoActivator.new

        expect { activator.deactivate(repo) }.to raise_error(Exception)
      end
    end
  end

  def stub_github_api
    hook = double(:hook, id: 1)
    api = double(
      :github_api,
      create_pull_request_hook: hook,
      remove_pull_request_hook: nil
    )
    GithubApi.stub(new: api)
    api
  end
end
