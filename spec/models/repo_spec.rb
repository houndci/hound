require "rails_helper"

describe Repo do
  it { should have_many :builds }
  it { should validate_presence_of :full_github_name }
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
        repo = Repo.new(full_github_name: "thoughtbot/hound")

        expect(repo).to be_bulk
      end
    end

    context "when repo is not bulk" do
      it "returns false" do
        repo = Repo.new(full_github_name: "jimbob/hound")

        expect(repo).not_to be_bulk
      end
    end

    context "without full_github_name" do
      it "returns false" do
        repo = Repo.new(full_github_name: nil)

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
        new_attributes = { github_id: 2, full_github_name: repo.name }

        Repo.find_or_create_with(new_attributes)
        repo.reload

        expect(Repo.count).to eq 1
        expect(repo.name).to eq new_attributes[:full_github_name]
        expect(repo.github_id).to eq new_attributes[:github_id]
      end
    end

    context "with existing github id" do
      it "updates attributes" do
        repo = create(:repo, full_github_name: "foo")
        new_attributes = { github_id: repo.github_id, full_github_name: "bar" }

        Repo.find_or_create_with(new_attributes)
        repo.reload

        expect(Repo.count).to eq 1
        expect(repo.github_id).to eq new_attributes[:github_id]
        expect(repo.name).to eq new_attributes[:full_github_name]
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
      it "repors update failure" do
        github_name = "foo/bar"
        github_id = 40023
        _repo_with_id = create(:repo, github_id: github_id)
        _repo_with_name = create(:repo, full_github_name: github_name)
        new_attributes = { github_id: github_id, full_github_name: github_name }
        allow(Raven).to receive(:capture_exception)

        Repo.find_or_create_with(new_attributes)

        expect(Raven).to have_received(:capture_exception).with(
          instance_of(ActiveRecord::RecordInvalid),
          extra: { github_id: github_id, full_github_name: github_name }
        )
      end
    end
  end
end
