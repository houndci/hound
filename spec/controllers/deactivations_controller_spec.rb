require "rails_helper"

describe DeactivationsController, "#create" do
  context "when deactivation succeeds" do
    it "returns successful response" do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, deactivate: true)
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(membership.user)
      expected_repo_json = RepoSerializer.new(
        repo,
        scope_name: :current_user,
        scope: membership.user,
      ).to_json

      post :create, params: { repo_id: repo.id }, format: :json

      expect(response).to have_http_status(:created)
      expect(response.body).to eq expected_repo_json
      expect(activator).to have_received(:deactivate)
      expect(RepoActivator).to have_received(:new).
        with(repo: repo, github_token: membership.user.token)
      expect(analytics).to have_tracked("Repo Deactivated").
        for_user(membership.user).
        with(
          properties: {
            name: repo.name,
            private: false,
            revenue: -membership.user.next_plan_price,
          }
        )
    end
  end

  context "when deactivation fails" do
    it "returns error response" do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, deactivate: false)
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(membership.user)

      post :create, params: { repo_id: repo.id }, format: :json

      expect(response.code).to eq "502"
      expect(activator).to have_received(:deactivate)
      expect(RepoActivator).to have_received(:new).
        with(repo: repo, github_token: membership.user.token)
    end
  end

  context "when repo has a subscription" do
    it "raises" do
      user = create(:user)
      repo = create(:repo, private: true, users: [user])
      create(:subscription, repo: repo)
      stub_sign_in(user)

      expect { post :create, params: { repo_id: repo.id }, format: :json }.
        to raise_error(
          DeactivationsController::CannotDeactivateRepoWithSubscription
        )
    end
  end

  context "when repo is private and does not have a subscription" do
    it "returns successful response" do
      user = create(:user)
      repo = create(:repo, private: true, users: [user])
      activator = double(:repo_activator, deactivate: true)
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(user)

      post :create, params: { repo_id: repo.id }, format: :json

      expect(response.code).to eq "201"
    end
  end
end
