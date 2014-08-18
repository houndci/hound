require "spec_helper"

describe SubscriptionsController, "#create" do
  it "subscribes the user to the repo" do
    membership = create(:membership)
    repo = membership.repo
    activator = double(:repo_activator, activate: true)
    RepoActivator.stub(new: activator)
    RepoSubscriber.stub(subscribe: true)
    stub_sign_in(membership.user)

    post(
      :create,
      repo_id: repo.id,
      card_token: "cardtoken",
      email_address: "jimtom@example.com",
      format: :json
    )

    expect(activator).to have_received(:activate).
      with(repo, AuthenticationHelper::GITHUB_TOKEN)
    expect(RepoSubscriber).to have_received(:subscribe).
      with(repo, membership.user, "cardtoken")
    expect(analytics).to have_tracked("Subscribed Private Repo").
      for_user(membership.user).
      with(properties: { name: repo.full_github_name, revenue: repo.price })
  end

  it "updates the current user's email address" do
    user = create(:user, email_address: nil)
    repo = create(:repo)
    user.repos << repo
    activator = double(:repo_activator, activate: true)
    RepoActivator.stub(new: activator)
    RepoSubscriber.stub(subscribe: true)
    stub_sign_in(user)

    post(
      :create,
      repo_id: repo.id,
      card_token: "cardtoken",
      email_address: "jimtom@example.com",
      format: :json
    )

    expect(user.reload.email_address).to eq "jimtom@example.com"
  end

  context "when subscription fails" do
    it "deactivates repo" do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, activate: true, deactivate: nil)
      RepoActivator.stub(new: activator)
      RepoSubscriber.stub(subscribe: false)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq "502"
      expect(activator).to have_received(:deactivate)
    end
  end
end

describe SubscriptionsController, "#destroy" do
  it "unsubscribes the user to the repo" do
    membership = create(:membership)
    repo = membership.repo
    activator = double(:repo_activator, deactivate: true)
    RepoActivator.stub(new: activator)
    RepoSubscriber.stub(unsubscribe: true)
    stub_sign_in(membership.user)

    delete(
      :destroy,
      repo_id: repo.id,
      card_token: "cardtoken",
      format: :json
    )

    expect(activator).to have_received(:deactivate).
      with(repo, AuthenticationHelper::GITHUB_TOKEN)
    expect(RepoSubscriber).to have_received(:unsubscribe).
      with(repo, membership.user)
    expect(analytics).to have_tracked("Unsubscribed Private Repo").
      for_user(membership.user).
      with(properties: { name: repo.full_github_name, revenue: repo.price })
  end
end
