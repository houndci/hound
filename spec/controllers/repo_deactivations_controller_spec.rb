require 'spec_helper'

describe RepoDeactivationsController do
  describe '#create' do
    it 'deactivates repo' do
      sign_in
      repo = Repo.create(github_id: 123, active: true)

      post :create, github_id: 123

      expect(repo.reload).to_not be_active
    end
  end
end
