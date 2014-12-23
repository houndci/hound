require "spec_helper"

describe Repo do
  it { should have_many(:users).through(:memberships) }
  it { should have_many :builds }
  it { should validate_presence_of :full_github_name }
  it { should validate_presence_of :github_id }

  it "validates uniqueness of github_id" do
    create(:repo)

    expect(subject).to validate_uniqueness_of(:github_id)
  end

  describe "#exempt?" do
    context "when repo is exempt" do
      it "returns true" do
        repo = Repo.new(full_github_name: "thoughtbot/hound")

        expect(repo).to be_exempt
      end
    end

    context "when repo is not exempt" do
      it "returns false" do
        repo = Repo.new(full_github_name: "jimbob/hound")

        expect(repo).not_to be_exempt
      end
    end

    context "without exempt organizations" do
      it "returns false" do
        without_exempt_organizations

        repo = Repo.new(full_github_name: "jimbob/hound")

        expect(repo).not_to be_exempt
      end
    end

    context "without full_github_name" do
      it "returns false" do
        repo = Repo.new(full_github_name: nil)

        expect(repo).not_to be_exempt
      end
    end
  end

  describe "#stripe_subscription_id" do
    context "when subscription is nil" do
      it "returns nil" do
        repo = Repo.new

        expect(repo.stripe_subscription_id).to be_nil
      end
    end

    context "when subscription is present" do
      it "returns Stripe subscription ID" do
        subscription = build(:subscription, stripe_subscription_id: "abc123")
        repo = subscription.repo

        expect(repo.stripe_subscription_id).to eq "abc123"
      end
    end
  end

  describe "#plan_type" do
    context "when repo is public" do
      it "returns public plan type" do
        repo = Repo.new(private: false)

        expect(repo.plan_type).to eq "public"
      end
    end

    context "when repo is private" do
      it "returns private plan type" do
        repo = Repo.new(private: true)

        expect(repo.plan_type).to eq "private"
      end
    end
  end

  describe "#enable" do
    it "updates repo enabled value to true" do
      repo = create(:repo, enabled: false)

      repo.enable

      expect(repo.reload).to be_enabled
    end
  end

  describe "#disable" do
    it "updates repo enabled value to false" do
      repo = create(:repo, enabled: true)

      repo.disable

      expect(repo.reload).not_to be_enabled
    end
  end

  describe ".find_or_create_with" do
    context "with existing repo" do
      it "updates attributes" do
        repo = create(:repo)

        found_repo = Repo.find_or_create_with(github_id: repo.github_id)

        expect(Repo.count).to eq 1
        expect(found_repo).to eq repo
      end
    end

    context "with new repo" do
      it "creates repo with attributes" do
        attributes = build(:repo).attributes
        repo = Repo.find_or_create_with(attributes)

        expect(Repo.count).to eq 1
        expect(repo).to be_present
      end
    end
  end

  describe ".find_and_update" do
    context "when repo name doesn't match db record" do
      it "updates the record" do
        new_repo_name = "new/name"
        repo = create(:repo, name: "foo/bar")

        Repo.find_and_update(repo.github_id, new_repo_name)
        repo.reload

        expect(repo.full_github_name).to eq new_repo_name
      end
    end
  end

  def without_exempt_organizations
    allow(ENV).to receive(:[]).with("EXEMPT_ORGS")
  end
end
