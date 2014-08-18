require 'spec_helper'

describe DeactivationsController, '#create' do
  context 'when deactivation succeeds' do
    it 'returns successful response' do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, deactivate: true)
      RepoActivator.stub(new: activator)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq '201'
      expect(response.body).to eq RepoSerializer.new(repo).to_json
      expect(activator).to have_received(:deactivate).with(
        repo,
        AuthenticationHelper::GITHUB_TOKEN
      )
      expect(analytics).to have_tracked("Deactivated Public Repo").
        for_user(membership.user).
        with(properties: { name: repo.full_github_name, revenue: repo.price })
    end
  end

  context 'when deactivation fails' do
    it 'returns error response' do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, deactivate: false)
      RepoActivator.stub(new: activator)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq '502'
      expect(activator).to have_received(:deactivate).with(
        repo,
        AuthenticationHelper::GITHUB_TOKEN
      )
    end

    it 'notifies Sentry' do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, deactivate: false)
      RepoActivator.stub(new: activator)
      Raven.stub(:capture_exception)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, format: :json

      expect(Raven).to have_received(:capture_exception).with(
        DeactivationsController::FailedToActivate.new(
          'Failed to deactivate repo'
        ),
        extra: { user_id: membership.user.id, repo_id: repo.id.to_s }
      )
    end
  end
end
