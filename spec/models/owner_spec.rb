require "rails_helper"

describe Owner do
  it { should have_many(:repos) }

  describe ".upsert" do
    context "when owner does not exist" do
      it "creates owner" do
        github_id = 1234
        name = "thoughtbot"
        organization = true

        new_owner = Owner.upsert(
          github_id: github_id,
          name: name,
          organization: organization
        )

        expect(new_owner).to be_persisted
      end
    end

    context "when owner exists" do
      it "updates owner" do
        owner = create(:owner)
        new_name = "ralphbot"

        updated_owner = Owner.upsert(
          github_id: owner.github_id,
          name: new_name,
          organization: true
        )

        expect(updated_owner.name).to eq new_name
        expect(updated_owner.organization).to eq true
      end
    end
  end

  describe "#has_config_repo?" do
    context "when the owner has a config repo set and enabled" do
      it "returns true" do
        owner = create(:owner, config_repo: "org/style", config_enabled: true)

        expect(owner).to have_config_repo
      end
    end

    context "when the owner has a config repo set and disabled" do
      it "returns false" do
        owner = create(:owner, config_repo: "org/style", config_enabled: false)

        expect(owner).not_to have_config_repo
      end
    end

    context "when the owner does not have a config repo set" do
      it "returns false" do
        owner = create(:owner, config_repo: "")

        expect(owner).not_to have_config_repo
      end
    end
  end

  describe "#hound_config" do
    it "is the content of the owner's Hound configuration" do
      config = instance_double("HoundConfig")
      owner = create(:owner)
      allow(BuildOwnerHoundConfig).to receive(:run).and_return(config)

      expect(owner.hound_config).to eq config
    end
  end
end
