require 'fast_spec_helper'
require 'app/services/repo_activator'

describe RepoActivator do
  describe '#activate' do
    context 'with existing repo' do
      it 'activates existing repo' do
        repo = mock(:activate)
        user = stub(github_repo: repo)
        api = mock(:create_pull_request_hook)
        activator = RepoActivator.new

        activator.activate(123, 'jimtom/repo', user, api, 'http://example.com')

        expect(user).to have_received(:github_repo).with(123)
        expect(repo).to have_received(:activate)
      end

      it 'creates GitHub hook' do
        repo = mock(:activate)
        user = stub(github_repo: repo)
        api = mock(:create_pull_request_hook)
        activator = RepoActivator.new

        activator.activate(123, 'jimtom/repo', user, api, 'http://example.com')

        expect(api).to have_received(:create_pull_request_hook).
          with('jimtom/repo', 'http://example.com/builds')
      end
    end

    context 'without existing repo' do
      it 'creates new active repo' do
        user = stub(github_repo: nil, create_github_repo: nil)
        api = mock(:create_pull_request_hook)
        activator = RepoActivator.new

        activator.activate(123, 'jimtom/repo', user, api, 'http://example.com')

        expect(user).to have_received(:create_github_repo).with(github_id: 123, active: true)
      end

      it 'creates GitHub hook' do
        user = stub(github_repo: nil, create_github_repo: nil)
        api = mock(:create_pull_request_hook)
        activator = RepoActivator.new

        activator.activate(123, 'jimtom/repo', user, api, 'http://example.com')

        expect(api).to have_received(:create_pull_request_hook).
          with('jimtom/repo', 'http://example.com/builds')
      end
    end
  end
end
