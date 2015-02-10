require "spec_helper"

describe ActivationsController, "#create" do
  context "when activation succeeds" do
    it "returns successful response" do
      token = "sometoken"
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, activate: true)
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(membership.user, token)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq "201"
      expect(response.body).to eq RepoSerializer.new(repo).to_json
      expect(activator).to have_received(:activate)
      expect(RepoActivator).to have_received(:new).
        with(repo: repo, github_token: token)
      expect(analytics).to have_tracked("Repo Activated").
        for_user(membership.user).
        with(
          properties: {
            name: repo.full_github_name,
            private: false,
            revenue: 0,
          }
        )
    end
  end

  context "when activation fails" do
    it "returns error response" do
      token = "sometoken"
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, activate: false).as_null_object
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(membership.user, token)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq "502"
      expect(activator).to have_received(:activate)
      expect(RepoActivator).to have_received(:new).
        with(repo: repo, github_token: token)
    end
  end

  context "when repo is not public" do
    it "does not activate" do
      repo = create(:repo, private: true)
      user = create(:user)
      user.repos << repo
      activator = double(:repo_activator, activate: false)
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(user)

      expect { post :create, repo_id: repo.id, format: :json }.to raise_error(
        ActivationsController::CannotActivatePaidRepo
      )
      expect(activator).not_to have_received(:activate)
    end
  end
end
