require 'spec_helper'

describe RepoActivationsController do
  describe '#create' do
    it 'activates repo' do
      user = FactoryGirl.create(:user)
      stub_sign_in(user)
      repo = mock(:activate)
      Repo.stubs(find_by_github_id_and_user: repo)

      post :create, github_id: 123

      expect(Repo).to have_received(:find_by_github_id_and_user).with('123', user)
      expect(repo).to have_received(:activate)
    end
  end
end
