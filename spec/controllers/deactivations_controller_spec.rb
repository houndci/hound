require 'spec_helper'

describe DeactivationsController, '#create' do
  context 'when repo is deactivated' do
    it 'activates repo' do
      membership = setup_request(true)
      activator = double(:repo_activator, deactivate: true)
      RepoActivator.stub(new: activator)
      membership = create(:membership)
      stub_sign_in(membership.user)

      post(:create, repo_id: membership.repo.id, format: :json)

      expect(activator).to have_received(:deactivate).with(membership.repo)
    end

    it 'errors when there is an issue deactivating a repo' do
      membership = setup_request(false)

      response = post(:create, repo_id: membership.repo.id, format: :json)

      expect(response.code).to eq '502'
    end
  end

  def setup_request(success)
    activator = double(:repo_activator, deactivate: success)
    RepoActivator.stub(new: activator)
    membership = create(:membership)
    stub_sign_in(membership.user)

    membership
  end
end
