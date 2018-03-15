# frozen_string_literal: true

require "rails_helper"

describe BuildOwnerHoundConfig do
  describe "#call" do
    context "when the owner has a configuration set" do
      it "returns the owner's config merged with the default HoundConfig" do
        github_api = instance_double("GithubApi", repo: "")
        owner = instance_double(
          "Owner",
          has_config_repo?: true,
          config_repo: "thoughtbot/guides",
        )
        commit = stub_commit(
          ".hound.yml" => <<~EOS
            remark:
              enabled: true
          EOS
        )
        allow(Commit).to receive(:new).and_return(commit)
        allow(GithubApi).to receive(:new).and_return(github_api)

        owner_config = BuildOwnerHoundConfig.call(owner)

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

        owner_config = BuildOwnerHoundConfig.call(owner)

        expect(owner_config.content).to eq(default_hound_config)
      end
    end

    context "when the owner's configuration is unreachable" do
      it "returns the default HoundConfig" do
        github_api = instance_double("GithubApi")
        owner = instance_double(
          "Owner",
          has_config_repo?: true,
          config_repo: "organization/private_style_guides",
        )
        allow(GithubApi).to receive(:new).and_return(github_api)
        allow(github_api).to receive(:repo).and_raise(Octokit::NotFound)

        owner_config = BuildOwnerHoundConfig.call(owner)

        expect(owner_config.content).to eq(default_hound_config)
      end
    end

    context "when the owner's configuration is improperly formatted" do
      it "returns the default HoundConfig" do
        github_api = instance_double("GithubApi")
        owner = instance_double(
          "Owner",
          has_config_repo?: true,
          config_repo: "not/a/valid/repo",
        )
        allow(GithubApi).to receive(:new).and_return(github_api)
        allow(github_api).to receive(:repo).
          and_raise(Octokit::InvalidRepository)

        owner_config = BuildOwnerHoundConfig.call(owner)

        expect(owner_config.content).to eq(default_hound_config)
      end
    end
  end

  def default_hound_config
    HoundConfig.new(EmptyCommit.new).content
  end
end
