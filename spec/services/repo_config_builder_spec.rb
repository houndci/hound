require "rails_helper"

describe RepoConfigBuilder do
  describe "#config_for" do
    context "for ruby" do
      it "returns the yaml formatted config" do
        owner = build(:owner)
        repo = build(:repo, owner: owner)
        merged_config = { "hey" => "yo" }
        token = "token"
        stub_github(token)
        stub_hound_config
        stub_ruby_config(merged_config)
        expected_yaml = YAML.dump(merged_config)

        repo_config_builder = RepoConfigBuilder.new(repo: repo, token: token)
        config = repo_config_builder.config_for("ruby")

        expect(config.content).to eq expected_yaml
        expect(config.format).to eq :yaml
      end
    end

    context "for an unsupported linter" do
      it "returns nil" do
        repo = build(:repo)
        repo_config_builder = RepoConfigBuilder.new(repo: repo, token: "hi")

        config = repo_config_builder.config_for("nope")

        expect(config).to be_nil
      end
    end
  end

  def stub_github(token)
    response_repo = { "default_branch" => "master" }
    github_api = double(GithubApi, repo: response_repo)
    allow(GithubApi).to receive(:new).with(token).and_return(github_api)
  end

  def stub_hound_config
    hound_config = double(HoundConfig)
    allow(HoundConfig).to receive(:new).and_return(hound_config)
  end

  def stub_ruby_config(config)
    ruby_config = double(Config::Ruby, content: {})
    allow(Config::Ruby).to receive(:new).and_return(ruby_config)
    ruby_config_builder = double(RubyConfigBuilder, config: config)
    allow(RubyConfigBuilder).to receive(:new).and_return(ruby_config_builder)
  end
end
