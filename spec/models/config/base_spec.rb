# frozen_string_literal: true

require "spec_helper"
require "app/models/config/base"
require "app/models/config/parser_error"
require "app/models/config_content"
require "app/models/config_content/remote"
require "app/models/missing_owner"
require "faraday"
require "yaml"

class Config::Test < Config::Base
  def serialize(content)
    ensure_correct_type(content).to_yaml
  end

  private

  def parse(file_content)
    YAML.load(file_content)
  end
end

describe Config::Base do
  describe "#content" do
    context "when an owner is provided" do
      it "merges the loaded config with the owner's" do
        commit = instance_double("Commit")
        config_content = instance_double(
          "ConfigContent",
          load: {
            "LineLength" => {
              "Max" => 90,
            },
          },
        )
        content = { "test" => {} }
        hound_config = instance_double(
          "HoundConfig",
          commit: commit,
          content: content,
        )
        owner_config_content = {
          "Metrics/ClassLength" => {
            "Max" => 100,
          },
        }
        owner = instance_double("Owner", config_content: owner_config_content)
        config = build_config(hound_config: hound_config, owner: owner)
        allow(ConfigContent).to receive(:new).and_return(config_content)

        expect(config.content).to eq(
          "LineLength" => { "Max" => 90 },
          "Metrics/ClassLength" => { "Max" => 100 },
        )
      end
    end

    context "when there is no owner" do
      it "returns the loaded config" do
        commit = instance_double("Commit")
        config_content = instance_double(
          "ConfigContent",
          load: {
            "LineLength" => {
              "Max" => 90,
            },
          },
        )
        hound_config_content = { "test" => {} }
        hound_config = instance_double(
          "HoundConfig",
          commit: commit,
          content: hound_config_content,
        )
        config = build_config(hound_config: hound_config)
        allow(ConfigContent).to receive(:new).and_return(config_content)

        expect(config.content).to eq("LineLength" => { "Max" => 90 })
      end
    end

    context "when there is a problem loading the content" do
      it "raises an exception" do
        commit = instance_double("Commit")
        content = { "test" => {} }
        hound_config = instance_double(
          "HoundConfig",
          commit: commit,
          content: content,
        )
        config = build_config(hound_config: hound_config)
        allow(ConfigContent).to receive(:new).
          and_raise(ConfigContent::ContentError, "Oops! Something went wrong")

        expect { config.content }.
          to raise_error(Config::ParserError, "Oops! Something went wrong")
      end
    end
  end

  def build_config(hound_config: build_hound_config, owner: MissingOwner.new)
    Config::Test.new(hound_config, owner: owner)
  end

  def build_hound_config
    double(
      "HoundConfig",
      commit: double("Commit", file_content: ""),
      content: {
        "test" => { "config_file" => "config-file.txt" },
      },
    )
  end
end
