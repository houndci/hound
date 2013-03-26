require 'fast_spec_helper'
require 'app/services/repo_activator'

describe RepoActivator do
  describe '#activate' do
    context 'with existing repo' do
      it 'activates existing repo' do
        repo = create(:repo)
        user = stub(github_repo: repo, github_token: nil)
        hook = stub(id: 1)
        api = GithubApi.new('authtoken')
        api.stubs(create_pull_request_hook: hook)
        activator = RepoActivator.new

        activator.activate(
          repo.github_id,
          repo.full_github_name,
          user,
          api,
          'http://example.com'
        )

        expect(user).to have_received(:github_repo).with(repo.github_id)
        expect(repo.active?).to be_true
      end

      it 'creates GitHub hook' do
        repo = create(:repo)
        user = stub(github_repo: repo, github_token: 'authtoken')
        hook = stub(id: 1)
        api = GithubApi.new('authtoken')
        api.stubs(create_pull_request_hook: hook)
        activator = RepoActivator.new

        activator.activate(
          repo.github_id,
          repo.full_github_name,
          user,
          api,
          'http://example.com'
        )

        expect(api).to have_received(:create_pull_request_hook).
          with(
            repo.full_github_name,
            'http://example.com/builds?token=authtoken'
          )
        expect(repo.hook_id).to eq 1
      end
    end

    context 'without existing repo' do
      it 'creates new active repo' do
        repo = mock(:update_attribute)
        user = mock(
          github_repo: nil,
          create_github_repo: repo,
          github_token: nil
        )
        hook = stub(id: 1)
        api = GithubApi.new('authtoken')
        api.stubs(create_pull_request_hook: hook)
        activator = RepoActivator.new

        activator.activate(123, 'jimtom/repo', user, api, 'http://example.com')

        expect(user).to have_received(:create_github_repo).
          with(github_id: 123, active: true, full_github_name: 'jimtom/repo')
        expect(repo).to have_received(:update_attribute)
      end

      it 'creates GitHub hook' do
        repo = mock(:update_attribute)
        user = stub(
          github_repo: nil,
          create_github_repo: repo,
          github_token: 'authtoken'
        )
        hook = stub(id: 1)
        api = GithubApi.new('authtoken')
        api.stubs(create_pull_request_hook: hook)
        activator = RepoActivator.new

        activator.activate(123, 'jimtom/repo', user, api, 'http://example.com')

        expect(api).to have_received(:create_pull_request_hook).
          with('jimtom/repo', 'http://example.com/builds?token=authtoken')
        expect(repo).to have_received(:update_attribute)
      end
    end
  end

  describe '#deactivate' do
    it 'deactivates repo' do
      api = stub
      api.stubs(remove_pull_request_hook: true)
      repo = Repo.new
      repo.stubs(full_github_name: 'jimtom/repo', hook_id: 1)
      activator = RepoActivator.new

      activator.deactivate(api, repo)

      expect(repo.active?).to be_false
    end

    it 'removes GitHub hook' do
      api = stub(:remove_pull_request_hook)
      repo = create(:repo, hook_id: 1)
      activator = RepoActivator.new

      activator.deactivate(api, repo)

      expect(api).to have_received(:remove_pull_request_hook)
      expect(repo.hook_id).to be_nil
    end

  end
end
