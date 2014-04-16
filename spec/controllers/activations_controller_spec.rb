require 'spec_helper'

describe ActivationsController, '#create' do
  context 'when activation succeeds' do
    it 'returns successful response' do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, activate: true)
      RepoActivator.stub(new: activator)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq '201'
      expect(response.body).to eq repo.to_json
      expect(activator).to have_received(:activate).with(
        repo,
        AuthenticationHelper::GITHUB_TOKEN
      )
    end
  end

  context 'when activation fails' do
    it 'returns error response' do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, activate: false)
      RepoActivator.stub(new: activator)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq '502'
      expect(activator).to have_received(:activate).with(
        repo,
        AuthenticationHelper::GITHUB_TOKEN
      )
    end

    it 'notifies Sentry' do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, activate: false)
      RepoActivator.stub(new: activator)
      Raven.stub(:capture_exception)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, format: :json

      expect(Raven).to have_received(:capture_exception).with(
        ActivationsController::FailedToActivate.new('Failed to activate repo'),
        extra: { repo_id: repo.id.to_s }
      )
    end
  end
end
