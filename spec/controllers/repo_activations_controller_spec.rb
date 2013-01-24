require 'spec_helper'

describe RepoActivationsController do
  describe '#create' do
    it 'activates repo' do
      stub_sign_in
      repo = mock(:activate)
      Repo.stubs(find_by_github_id: repo)

      post :create, github_id: 123

      expect(Repo).to have_received(:find_by_github_id).with('123')
      expect(repo).to have_received(:activate)
    end
  end
end
