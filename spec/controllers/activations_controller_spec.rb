require 'spec_helper'

describe ActivationsController, '#update' do
  context 'when repo is activated' do
    it 'deactivates repo' do
      activator = double(:repo_activator, activate: true)
      membership = setup_request(activator)

      post(:create, repo_id: membership.repo.id, format: :json)

      expect(activator).to have_received(:activate).
        with(membership.repo, membership.user)
    end

    it 'errors when there is an issue activating the repo' do
      activator = double(:repo_activator, activate: false)
      membership = setup_request(activator)

      response = post(:create, repo_id: membership.repo.id, format: :json)

      expect(response.code).to eq '502'
    end
  end

  def setup_request(activator)
    RepoActivator.stub(new: activator)
    membership = create(:membership)
    stub_sign_in(membership.user)

    membership
  end
end
