require "rails_helper"

describe BuildOwnerHoundConfig do
  describe "#run" do
    context "when the owner has a configuration set" do
      it "returns the configuration of that repo" do
        owner = instance_double(
          "Owner",
          has_config_repo?: true,
          config_repo: "thoughtbot/guides",
        )
        commit = stubbed_commit(
          ".hound.yml" => <<~EOS
            ruby:
              enabled: true
          EOS
        )
        allow(Commit).to receive(:new).and_return(commit)

        owner_config = BuildOwnerHoundConfig.run(owner)

        expect(owner_config.content).to eq("ruby" => { "enabled" => true })
      end
    end

    context "when the owner does not have a configuration set" do
      it "returns nil" do
        owner = instance_double(
          "Owner",
          has_config_repo?: false,
          config_repo: "thoughtbot/guides",
        )

        owner_config = BuildOwnerHoundConfig.run(owner)

        expect(owner_config).to be_nil
      end
    end

    context "when the owner's configuration is unreachable" do
      it "returns an empty hound config" do
        owner = instance_double(
          "Owner",
          has_config_repo?: true,
          config_repo: "organization/private_style_guides",
        )
        stub_failure_on_repo(repo: "organization/private_style_guides")

        owner_config = BuildOwnerHoundConfig.run(owner)

        expect(owner_config.content).to eq({})
      end
    end
  end

  def stub_failure_on_repo(repo:)
    stub_request(
      :get,
      %r"https://api.github.com/repos/#{repo}/contents/*",
    ).to_return(status: 404, headers: {})
  end
end
