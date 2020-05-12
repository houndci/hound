require "rails_helper"

describe User do
  it { should have_many(:repos).through(:memberships) }
  it { should have_many(:subscribed_repos).through(:subscriptions) }
  it { should validate_presence_of :username }
  it { should have_many(:memberships).dependent(:destroy) }

  describe "#current_plan" do
    it "returns the current plan" do
      user = User.new

      expect(user.current_plan).to eq StripePlan.new(**StripePlan::PLANS[0])
    end
  end

  describe "#next_plan" do
    it "returns the next plan" do
      user = User.new

      expect(user.next_plan).to eq StripePlan.new(**StripePlan::PLANS[1])
    end
  end

  describe "#plan_max" do
    it "returns the current plan's allowance" do
      user = User.new(subscribed_repos: Array.new(5) { Repo.new })

      expect(user.plan_max).to eq StripePlan::PLANS[2][:range].max
    end
  end

  describe "#next_plan_price" do
    it "returns the price of the next plan" do
      subscription = create(:subscription)
      user = subscription.user

      expect(user.next_plan_price).to eq 49
    end
  end

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

      expect(user_string).to eq user.username
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

  describe "#payment_gateway_subscription" do
    it "returns the subscriptions for the payment gateway customer" do
      subscription = instance_double("PaymentGatewaySubscription")
      customer = instance_double(
        "PaymentGatewayCustomer",
        subscription: subscription,
      )
      user = User.new
      allow(PaymentGatewayCustomer).to receive(:new).once.with(user).
        and_return(customer)

      expect(user.payment_gateway_subscription).to eq subscription
    end
  end
end
