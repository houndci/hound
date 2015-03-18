require "rails_helper"

describe Owner do
  it { should have_many(:repos) }
  it { should have_many(:style_configs).dependent(:destroy) }

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
end
