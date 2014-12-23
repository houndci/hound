require "spec_helper"

describe ActivationsController, "#create" do
  context "when activation succeeds" do
    it "returns successful response" do
      token = "sometoken"
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, enable: true)
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(membership.user, token)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq "201"
      expect(response.body).to eq RepoSerializer.new(repo).to_json
      expect(activator).to have_received(:enable)
      expect(RepoActivator).to have_received(:new).
        with(repo: repo, github_token: token)
      expect(analytics).to have_tracked("Enabled Public Repo").
        for_user(membership.user).
        with(properties: { name: repo.full_github_name })
    end
  end

  context "when activation fails" do
    it "returns error response" do
      token = "sometoken"
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, enable: false).as_null_object
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(membership.user, token)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq "502"
      expect(activator).to have_received(:enable)
      expect(RepoActivator).to have_received(:new).
        with(repo: repo, github_token: token)
    end

    it "notifies Sentry" do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, enable: false).as_null_object
      allow(RepoActivator).to receive(:new).and_return(activator)
      allow(Raven).to receive(:capture_exception)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, format: :json

      expect(Raven).to have_received(:capture_exception).with(
        ActivationsController::FailedToActivate.new("Failed to enable repo"),
        extra: { user_id: membership.user.id, repo_id: repo.id.to_s }
      )
    end
  end

  context "when repo is not public" do
    it "does not enable" do
      repo = create(:repo, private: true)
      user = create(:user)
      user.repos << repo
      activator = double(:repo_activator, enable: false)
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(user)

      expect { post :create, repo_id: repo.id, format: :json }.to raise_error(
        ActivationsController::CannotActivatePaidRepo
      )
      expect(activator).not_to have_received(:enable)
    end
  end
end
