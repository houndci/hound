require "rails_helper"

describe Repo do
  it { should have_many :builds }
  it { should validate_presence_of :github_id }
  it { should belong_to :owner }
  it { should have_many(:users).through(:memberships) }
  it { should have_many(:memberships).dependent(:destroy) }

  it "validates uniqueness of github_id" do
    create(:repo)

    expect(subject).to validate_uniqueness_of(:github_id)
  end

  describe "#bulk?" do
    context "when repo is bulk" do
      it "returns true" do
        create(:bulk_customer, org: "thoughtbot")
        repo = Repo.new(name: "thoughtbot/hub")

        expect(repo).to be_bulk
      end
    end

    context "when repo is not bulk" do
      it "returns false" do
        repo = Repo.new(name: "jimbob/hound")

        expect(repo).not_to be_bulk
      end
    end

    context "without name" do
      it "returns false" do
        repo = Repo.new(name: nil)

        expect(repo).not_to be_bulk
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

  describe "#activate" do
    it "updates repo active value to true" do
      repo = create(:repo, active: false)

      repo.activate

      expect(repo.reload).to be_active
    end
  end

  describe "#deactivate" do
    it "updates repo active value to false" do
      repo = create(:repo, active: true)

      repo.deactivate

      expect(repo.reload).not_to be_active
    end
  end

  describe ".find_or_create_with" do
    context "with existing github name" do
      it "updates attributes" do
        repo = create(:repo, github_id: 1)
        new_attributes = { github_id: 2, name: repo.name }

        Repo.find_or_create_with(new_attributes)
        repo.reload

        expect(Repo.count).to eq 1
        expect(repo.name).to eq new_attributes[:name]
        expect(repo.github_id).to eq new_attributes[:github_id]
      end
    end

    context "with existing github id" do
      it "updates attributes" do
        repo = create(:repo, name: "foo")
        new_attributes = { github_id: repo.github_id, name: "bar" }

        Repo.find_or_create_with(new_attributes)
        repo.reload

        expect(Repo.count).to eq 1
        expect(repo.github_id).to eq new_attributes[:github_id]
        expect(repo.name).to eq new_attributes[:name]
      end
    end

    context "with new repo" do
      it "creates repo with attributes" do
        repo = Repo.find_or_create_with(attributes_for(:repo))

        expect(Repo.count).to eq 1
        expect(repo.reload).to be_present
      end
    end

    context "when one repo has taken the github name and another taken id" do
      it "updates relying on github_id as the source of truth" do
        github_name = "foo/bar"
        github_id = 40023
        repo_with_id = create(:repo, github_id: github_id)
        _repo_with_name = create(:repo, name: github_name)
        new_attributes = { github_id: github_id, name: github_name }

        Repo.find_or_create_with(new_attributes)

        expect(repo_with_id.reload.name).to eq github_name
      end
    end
  end

  describe "#total_violations" do
    it "returns a sum of all the violations for the repo" do
      repo = create(:repo)
      create(:build, violations_count: 5, repo: repo)
      create(:build, violations_count: 3, repo: repo)

      expect(repo.total_violations).to eq 8
    end
  end
end
