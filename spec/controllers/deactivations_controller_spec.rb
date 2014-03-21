require 'spec_helper'

describe DeactivationsController, '#create' do
  context 'when repo is deactivated' do
    it 'activates repo' do
      activator = double(:repo_activator, deactivate: true)
      RepoActivator.stub(new: activator)
      membership = create(:membership)
      stub_sign_in(membership.user)

      post(:create, id: membership.repo.id, format: :json)

      expect(activator).to have_received(:deactivate).with(membership.repo)
    end
  end
end
