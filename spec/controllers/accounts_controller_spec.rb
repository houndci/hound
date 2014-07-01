require "spec_helper"

describe AccountsController do
  describe "#show" do
    it "assigns the repo variables" do
      user = create(:user)
      org_repo = create(:repo, :in_private_org, users: [user])
      personal_repo = create(:repo, private: true, users: [user])
      _inactive_repo = create(:repo, :in_private_org, users: [user])
      create(:subscription, repo: org_repo, user: user)
      create(:subscription, repo: personal_repo, user: user)
      create(:subscription, :inactive, user: user)
      stub_sign_in(user)

      get :show

      expect(assigns(:repos)).to eq [org_repo, personal_repo]
      expect(assigns(:org_repos)).to eq [org_repo]
      expect(assigns(:personal_repos)).to eq [personal_repo]
    end
  end
end
