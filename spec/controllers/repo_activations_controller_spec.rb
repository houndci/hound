require 'spec_helper'

describe RepoActivationsController do
  describe '#create' do
    it 'activates repo' do
      user = create(:user, github_token: 'authtoken')
      stub_sign_in(user)
      api = stub
      activator = mock(:activate)
      GithubApi.stubs(new: api)
      RepoActivator.stubs(new: activator)

      post :create, { github_id: 123, full_github_name: 'jimtom/repo' }

      expect(GithubApi).to have_received(:new).with(user.github_token)
      expect(activator).to have_received(:activate).
        with(123, 'jimtom/repo', user, api, 'http://test.host')
    end
  end

  describe '#destroy' do
    it 'deactivates repo' do
      user = create(:user, github_token: 'authtoken')
      stub_sign_in(user)
      api = stub
      activator = mock(:deactivate)
      repo = stub
      GithubApi.stubs(new: api)
      RepoActivator.stubs(new: activator)
      User.any_instance.stubs(github_repo: repo)

      post :destroy, { id: 1 }

      expect(GithubApi).to have_received(:new).with(user.github_token)
      expect(activator).to have_received(:deactivate).with(api, repo)
    end
  end
end
