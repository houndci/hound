require "rails_helper"

describe Owner do
  it { should have_many(:repos) }

  describe ".upsert" do
    context "when name exists" do
      it "captures exception, notifies raven, and raises to caller" do
        existing_name = "ralphbot"
        new_id = 567
        create(:owner, github_id: 1234, name: existing_name)
        allow(Raven).to receive(:capture_exception)

        expect do
          Owner.upsert(
            github_id: new_id,
            name: existing_name,
            organization: true,
          )
        end.to raise_exception(ActiveRecord::RecordNotUnique)

        expect(Raven).to have_received(:capture_exception).with(
          instance_of(ActiveRecord::RecordNotUnique),
          extra: {
            github_id: new_id,
            name: existing_name,
          },
        )
      end
    end

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

  describe "#config_content" do
    it "returns the content for a specific linter" do
      owner_hound_config = {
        "rubocop" => {
          "config_file" => ".rubocop.yml",
        },
      }
      owner_ruby_config = {
        "LineLength" => { "Max" => 90 },
      }
      owner_hound_contents = owner_hound_config.to_yaml
      owner_ruby_contents = owner_ruby_config.to_yaml
      owner = create(:owner, config_repo: "foo/bar", config_enabled: true)
      github_api = instance_double("GitHubApi", repo: true)
      allow(github_api).to receive(:file_contents).
        with("foo/bar", ".hound.yml", "HEAD").
        and_return(double(content: Base64.encode64(owner_hound_contents)))
      allow(github_api).to receive(:file_contents).
        with("foo/bar", ".rubocop.yml", "HEAD").
        and_return(double(content: Base64.encode64(owner_ruby_contents)))
      allow(GitHubApi).to receive(:new).and_return(github_api)

      expect(owner.config_content("rubocop")).to eq(owner_ruby_config)
    end
  end
end
