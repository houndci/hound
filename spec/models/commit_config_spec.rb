require "fast_spec_helper"
require "active_support/core_ext/string/strip"
require "app/models/commit_config"

describe CommitConfig do
  describe "#to_hash" do
    context "when config files have content" do
      it "returns config hash" do
        rubocop_content = <<-YAML.strip_heredoc
          StringLiterals:
            EnforcedStyle: single_quotes

          LineLength:
            Max: 90
        YAML
        hound_content = <<-YAML.strip_heredoc
          Include:
            - .rubocop.yml

          LineLength:
            Max: 100
        YAML
        commit = double(:commit)
        allow(commit).to receive(:file_content).
          with(CommitConfig::HOUND_CONFIG_FILE).
          and_return(hound_content)
        allow(commit).to receive(:file_content).
          with(".rubocop.yml").
          and_return(rubocop_content)
        commit_config = CommitConfig.new(commit)

        result = commit_config.to_hash

        expect(result).to eq(
          "StringLiterals" => { "EnforcedStyle" => "single_quotes" },
          "LineLength" => { "Max" => 100 },
        )
      end
    end

    context "when there is no config file" do
      it "returns empty hash" do
        commit = double(:commit, file_content: nil)
        commit_config = CommitConfig.new(commit)

        result = commit_config.to_hash

        expect(result).to eq({})
      end
    end
  end
end
