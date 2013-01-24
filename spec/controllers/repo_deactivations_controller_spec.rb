require 'spec_helper'

describe RepoDeactivationsController do
  describe '#create' do
    it 'deactivates repo' do
      user = FactoryGirl.create(:user)
      stub_sign_in(user)
      repo = stub(:deactivate)
      Repo.stubs(find_by_github_id_and_user: repo)

      post :create, github_id: 123

      expect(repo).to have_received(:deactivate)
    end
  end
end
