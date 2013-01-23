require 'spec_helper'

describe RepoActivationsController do
  describe '#create' do
    context 'without existing repo' do
      it 'creates an active repo' do
        sign_in

        post :create, 'github_id' => 123

        expect(Repo.where(github_id: 123, active: true)).to be_present
      end
    end

    context 'with existing repo' do
      it 'activates repo' do
        sign_in
        repo = Repo.create(github_id: 123, active: false)

        post :create, 'github_id' => 123

        expect(repo.reload).to be_active
      end
    end
  end
end
