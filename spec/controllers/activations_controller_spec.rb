require 'spec_helper'

describe ActivationsController, '#update' do
  context 'when repo is activated' do
    it 'deactivates repo' do
      activator = double(:repo_activator, activate: true)
      RepoActivator.stub(new: activator)
      membership = create(:membership)
      stub_sign_in(membership.user)

      patch(:create, id: membership.repo.id, format: :json)

      expect(activator).to have_received(:activate).
        with(membership.repo, membership.user)
    end
  end
end
