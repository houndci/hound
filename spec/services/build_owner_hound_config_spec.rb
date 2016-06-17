require "rails_helper"

describe BuildOwnerHoundConfig do
  describe "#run" do
    context "when the owner has a configuration set" do
      it "returns the owner's config merged with the default HoundConfig" do
        owner = instance_double(
          "Owner",
          has_config_repo?: true,
          config_repo: "thoughtbot/guides",
        )
        commit = stubbed_commit(
          ".hound.yml" => <<~EOS
            remark:
              enabled: true
          EOS
        )
        stub_success_on_repo("thoughtbot/guides")
        allow(Commit).to receive(:new).and_return(commit)

        owner_config = BuildOwnerHoundConfig.run(owner)

        expect(owner_config.content).
          to eq(default_hound_config.merge("remark" => { "enabled" => true }))
      end
    end

    context "when the owner does not have a configuration set" do
      it "returns the default HoundConfig" do
        owner = instance_double(
          "Owner",
          has_config_repo?: false,
          config_repo: "thoughtbot/guides",
        )

        owner_config = BuildOwnerHoundConfig.run(owner)

        expect(owner_config.content).to eq(default_hound_config)
      end
    end

    context "when the owner's configuration is unreachable" do
      it "returns the default HoundConfig" do
        owner = instance_double(
          "Owner",
          has_config_repo?: true,
          config_repo: "organization/private_style_guides",
        )
        stub_failure_on_repo("organization/private_style_guides")

        owner_config = BuildOwnerHoundConfig.run(owner)

        expect(owner_config.content).to eq(default_hound_config)
      end
    end

    context "when the owner's configuration is improperly formatted" do
      it "returns the default HoundConfig" do
        owner = instance_double(
          "Owner",
          has_config_repo?: true,
          config_repo: "not/a/valid/repo",
        )

        owner_config = BuildOwnerHoundConfig.run(owner)

        expect(owner_config.content).to eq(default_hound_config)
      end
    end
  end

  def stub_failure_on_repo(repo_name)
    stub_request(:get, %r"https://api.github.com/repos/#{repo_name}*").
      to_return(status: 404, headers: {})
  end

  def default_hound_config
    HoundConfig.new(EmptyCommit.new).content
  end
end
