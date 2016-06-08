require "rails_helper"

describe OwnerHoundConfigBuilder do
  describe "#run" do
    context "when the owner has a configuration set" do
      it "returns the configuration of that repo" do
        hound_config = instance_double("HoundConfig")
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
        repo = instance_double("Repo", owner: owner)

        owner_config = OwnerHoundConfigBuilder.run(repo, hound_config)

        expect(owner_config.content).to eq("ruby" => {"enabled" => true})
      end
    end

    context "when the owner does not have a configuration set"
      it "returns the default it was passed" do
        hound_config = instance_double("HoundConfig")
        owner = instance_double(
          "Owner",
          has_config_repo?: false,
          config_repo: "thoughtbot/guides",
        )
        repo = instance_double("Repo", owner: owner)

        owner_config = OwnerHoundConfigBuilder.run(repo, hound_config)

        expect(owner_config).to eq(hound_config)
      end
  end
end
