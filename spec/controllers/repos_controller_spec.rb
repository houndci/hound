require 'spec_helper'

describe ReposController, '#update' do
  context 'when repo is deactivated' do
    it 'activates repo' do
      activator = stub(:activate)
      RepoActivator.stubs(new: activator)
      user = create(:user)
      repo = create(:repo, user: user)
      stub_sign_in(user)

      put(:update, id: repo.id, active: true)

      expect(activator).to have_received(:activate).with(repo)
    end
  end

  context 'when repo is activated' do
    it 'deactivates repo' do
      activator = stub(:deactivate)
      RepoActivator.stubs(new: activator)
      user = create(:user)
      repo = create(:repo, user: user)
      stub_sign_in(user)

      put(:update, id: repo.id, active: false)

      expect(activator).to have_received(:deactivate).with(repo)
    end
  end
end
