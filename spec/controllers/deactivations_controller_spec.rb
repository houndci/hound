require "spec_helper"

describe DeactivationsController, "#create" do
  context "when deactivation succeeds" do
    it "returns successful response" do
      token = "sometoken"
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, deactivate: true)
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(membership.user, token)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq "201"
      expect(response.body).to eq RepoSerializer.new(repo).to_json
      expect(activator).to have_received(:deactivate)
      expect(RepoActivator).to have_received(:new).
        with(repo: repo, github_token: token)
      expect(analytics).to have_tracked("Deactivated Public Repo").
        for_user(membership.user).
        with(properties: { name: repo.full_github_name })
    end
  end

  context "when deactivation fails" do
    it "returns error response" do
      token = "sometoken"
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, deactivate: false)
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(membership.user, token)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq "502"
      expect(activator).to have_received(:deactivate)
      expect(RepoActivator).to have_received(:new).
        with(repo: repo, github_token: token)
    end
  end

  context "when repo has a subscription" do
    it "raises" do
      repo = create(:repo, private: true)
      create(:subscription, repo: repo)
      user = repo.users.first
      stub_sign_in(user)

      expect { post :create, repo_id: repo.id, format: :json }.
        to raise_error(
          DeactivationsController::CannotDeactivateRepoWithSubscription
        )
    end
  end

  context "when repo is private and does not have a subscription" do
    it "returns successful response" do
      repo = create(:repo, private: true)
      user = repo.users.first
      activator = double(:repo_activator, deactivate: true)
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(user)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq "201"
    end
  end
end
