require 'spec_helper'

describe RepoActivationsController do
  describe '#create' do
    it 'activates repo' do
      user = create(:user, github_token: 'authtoken')
      stub_sign_in(user)
      api = stub
      GithubApi.stubs(new: api)
      activator = mock(:activate)
      RepoActivator.stubs(new: activator)

      post :create, { github_id: 123, full_github_name: 'jimtom/repo' }

      expect(GithubApi).to have_received(:new).with(user.github_token)
      expect(activator).to have_received(:activate).
        with(123, 'jimtom/repo', user.repos, api, 'http://test.host')
    end
  end
end
