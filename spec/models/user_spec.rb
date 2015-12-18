require "rails_helper"

describe User do
  it { should have_many(:repos).through(:memberships) }
  it { should have_many(:subscribed_repos).through(:subscriptions) }
  it { should validate_presence_of :github_username }
  it { should have_many(:memberships).dependent(:destroy) }

  describe "#subscribed_repos" do
    it "returns subscribed repos" do
      user = create(:user)
      _unsubscribed_repo = create(:repo, users: [user])
      _inactive_subscription = create(:subscription, :inactive, user: user)
      active_subscription = create(:subscription, user: user)

      repos = user.subscribed_repos

      expect(repos).to eq [active_subscription.repo]
    end
  end

  describe "#repos_by_activation_ability" do
    it "orders active repos with admin permissions first then by name" do
      repo1 = create(:repo, name: "foo", active: false)
      repo2 = create(:repo, name: "bar", active: false)
      repo3 = create(:repo, name: "baz", active: true)
      user = create(:user)
      create(:membership, user: user, repo: repo1, admin: false)
      create(:membership, user: user, repo: repo2, admin: true)
      create(:membership, user: user, repo: repo3, admin: true)

      results = user.repos_by_activation_ability

      expect(results).to eq [repo3, repo2, repo1]
    end
  end

  describe '#create' do
    it 'generates a remember_token' do
      user = build(:user)
      allow(SecureRandom).to receive(:hex) { "remembertoken" }

      user.save

      expect(SecureRandom).to have_received(:hex).with(20)
      expect(user.remember_token).to eq 'remembertoken'
    end
  end

  describe "#token" do
    it "generates saves encrypted token in database" do
      user = build(:user)
      user.token = "original-token"

      user.save

      expect(user["token"]).to_not eq(user.token)
      expect(user["token"]).to_not eq("original-token")
    end

    it "returns original value of token on call" do
      user = build(:user)
      user.token = "original-token"

      user.save

      expect(user.reload.token).to eq("original-token")
    end
  end

  describe '#to_s' do
    it 'returns GitHub username' do
      user = build(:user)

      user_string = user.to_s

      expect(user_string).to eq user.github_username
    end
  end

  describe "#active_repos" do
    it "returns active repos" do
      user = create(:user)
      active_repo = create(:repo, :active, users: [user])
      create(:repo, :inactive, users: [user])

      expect(user.active_repos).to eq([active_repo])
    end
  end

  describe '#has_repos_with_missing_information?' do
    context 'with repo without organization info' do
      it 'returns true' do
        user = create(:user)
        repo = create(:repo, in_organization: nil)
        user.repos << repo

        expect(user).to have_repos_with_missing_information
      end
    end

    context 'with repo without privacy info' do
      it 'return true' do
        user = create(:user)
        repo = create(:repo, private: nil)
        user.repos << repo

        expect(user).to have_repos_with_missing_information
      end
    end

    context 'with repo without organization and privacy info' do
      it 'returns true' do
        user = create(:user)
        repo = create(:repo, in_organization: nil, private: nil)
        user.repos << repo

        expect(user).to have_repos_with_missing_information
      end
    end

    context 'with repo with organization and privacy info' do
      it 'returns false' do
        user = create(:user)
        repo = create(:repo, in_organization: true, private: true)
        user.repos << repo

        expect(user).not_to have_repos_with_missing_information
      end
    end
  end

  describe "#has_access_to_private_repos?" do
    context "when token scopes include repo" do
      it "returns true" do
        user = User.new(token_scopes: "repo,user:email")

        expect(user).to have_access_to_private_repos
      end
    end

    context "when token scopes don't include repo" do
      it "returns false" do
        user = User.new(token_scopes: "public_repo,user:email")

        expect(user).not_to have_access_to_private_repos
      end
    end
  end
end
