require "spec_helper"
require "app/models/config/base"
require "app/models/config/parser"
require "app/models/config/jshint"
require "app/models/config/serializer"
require "app/models/mergeable_config_builder"

describe MergeableConfigBuilder do
  describe ".for" do
    context "when there is a jshint configuration" do
      it "takes a hound config and returns a jshint config" do
        commit = stubbed_commit(".jshintrc" => <<~CON)
          {
            "undef": true,
            "unused": true,
            "predef": [ "MY_GLOBAL" ]
          }
        CON
        hound_config = double(
          "HoundConfig",
          commit: commit,
          content: { "jshint" => { "config_file" => ".jshintrc" } },
        )

        config = MergeableConfigBuilder.for(hound_config, "jshint")

        expect(config).to be_a(Config::Jshint)
        expect(config.serialize).to eq(
          '{"undef":true,"unused":true,"predef":["MY_GLOBAL"]}',
        )
      end

      it "takes a hound config and returns a config with the given content" do
        commit = stubbed_commit(".jshintrc" => <<~CON)
          {
            "undef": true,
            "unused": true,
            "predef": [ "MY_GLOBAL" ]
          }
        CON
        hound_config = double(
          "HoundConfig",
          commit: commit,
          content: { "jshint" => { "config_file" => ".jshintrc" } },
        )

        result = MergeableConfigBuilder.for(hound_config, "jshint").serialize

        expect(result).to eq(
          '{"undef":true,"unused":true,"predef":["MY_GLOBAL"]}',
        )
      end
    end

    context "when there is not a jshint configuration" do
      it "returns a configuration with default content" do
        hound_config = double(
          "HoundConfig",
          content: {},
        )

        config = MergeableConfigBuilder.for(hound_config, "jshint")

        expect(config.serialize).to eq("{}")
      end
    end
  end
end
