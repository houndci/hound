require "spec_helper"
require "app/models/config/base"
require "app/models/config/parser"
require "app/models/config/jshint"
require "app/models/jshint_config_builder"

describe JshintConfigBuilder do
  describe ".for" do
    context "when there is a jshint configuration" do
      it "takes a hound config and returns a jshint config with content" do
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

        config = JshintConfigBuilder.for(hound_config)

        expect(config).to be_a(Config::Jshint)
        expect(config.content).to eq(
          "undef" => true,
          "unused" => true,
          "predef" => ["MY_GLOBAL"],
        )
      end
    end

    context "when there is not a jshint configuration" do
      it "returns a jshint with default config" do
        hound_config = double(
          "HoundConfig",
          content: {},
        )

        config = JshintConfigBuilder.for(hound_config)

        expect(config).to be_a(Config::Jshint)
        expect(config.content).to eq({})
      end
    end
  end
end
