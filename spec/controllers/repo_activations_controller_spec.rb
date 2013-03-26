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
      GithubApi.stubs(new: api)
      activator = mock(:deactivate)
      RepoActivator.stubs(new: activator)
      repo = build_stubbed(:repo, user_id: user.id)
      User.any_instance.stubs(github_repo: repo)

      post :destroy, { id: repo.id }

      expect(GithubApi).to have_received(:new).with(user.github_token)
      expect(activator).to have_received(:deactivate).with(api, repo)
      expect(repo.active?).to be_false
      expect(repo.hook_id).to be_nil
    end
  end
end
