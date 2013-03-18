require 'fast_spec_helper'
require 'app/services/repo_activator'

describe RepoActivator do
  describe '#activate' do
    context 'with existing repo' do
      it 'activates existing repo' do
        repo = mock({
          activate: true,
          update_hook_id: true
        })
        user = mock(github_repo: repo, github_token: nil)
        hook = stub(id: 1)
        api = GithubApi.new('authtoken')
        api.stubs(:create_pull_request_hook).returns(hook)
        activator = RepoActivator.new

        activator.activate(123, 'jimtom/repo', user, api, 'http://example.com')

        expect(user).to have_received(:github_repo).with(123)
        expect(repo).to have_received(:activate)
        expect(repo).to have_received(:update_hook_id).with(1)
      end

      it 'creates GitHub hook' do
        repo = mock({
          activate: true,
          update_hook_id: true
        })
        user = stub(github_repo: repo, github_token: 'authtoken')
        hook = stub(:id)
        api = GithubApi.new('authtoken')
        api.stubs(:create_pull_request_hook).returns(hook)
        activator = RepoActivator.new

        activator.activate(123, 'jimtom/repo', user, api, 'http://example.com')

        expect(api).to have_received(:create_pull_request_hook).
          with('jimtom/repo', 'http://example.com/builds?token=authtoken')
      end
    end

    context 'without existing repo' do
      it 'creates new active repo' do
        repo = mock(:update_hook_id)
        user = mock(
          github_repo: nil,
          create_github_repo: repo,
          github_token: nil
        )
        hook = stub(id: 1)
        api = GithubApi.new('authtoken')
        api.stubs(:create_pull_request_hook).returns(hook)
        activator = RepoActivator.new

        activator.activate(123, 'jimtom/repo', user, api, 'http://example.com')

        expect(user).to have_received(:create_github_repo).
          with(github_id: 123, active: true, full_github_name: 'jimtom/repo')
        expect(repo).to have_received(:update_hook_id).with(1)
      end

      it 'creates GitHub hook' do
        repo = mock(:update_hook_id)
        user = stub(
          github_repo: nil,
          create_github_repo: repo,
          github_token: 'authtoken'
        )
        hook = stub(id: 1)
        api = GithubApi.new('authtoken')
        api.stubs(:create_pull_request_hook).returns(hook)
        activator = RepoActivator.new

        activator.activate(123, 'jimtom/repo', user, api, 'http://example.com')

        expect(api).to have_received(:create_pull_request_hook).
          with('jimtom/repo', 'http://example.com/builds?token=authtoken')
        expect(repo).to have_received(:update_hook_id).with(1)
      end
    end
  end

  describe '#deactivate' do
    it 'deactivates repo' do
      api = stub
      api.stubs(:remove_pull_request_hook).returns(true)
      repo = Repo.new
      repo.stubs(full_github_name: 'jimtom/repo', hook_id: 1, deactivate: true)
      activator = RepoActivator.new

      activator.deactivate(api, repo)

      expect(repo).to have_received(:full_github_name)
      expect(repo).to have_received(:deactivate)
    end

    it 'removes GitHub hook' do
      api = stub(:remove_pull_request_hook)
      repo = create(:repo)
      activator = RepoActivator.new

      activator.deactivate(api, repo)

      expect(api).to have_received(:remove_pull_request_hook)
    end

  end
end
