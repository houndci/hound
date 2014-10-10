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
end
