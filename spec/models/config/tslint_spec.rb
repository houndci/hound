require "spec_helper"
require "app/models/config/base"
require "app/models/config/tslint"
require "app/models/config/parser"
require "app/models/config/parser_error"
require "app/models/config/serializer"
require "app/models/config/json_with_comments"
require "app/models/missing_owner"

describe Config::Tslint do
  describe "#content" do
    it "parses the configuration using JSON" do
      raw_config = <<~EOS
        {
          "rules": {
            "no-constructor-vars": true
          }
        }
      EOS
      commit = stubbed_commit("config/tslint.json" => raw_config)
      config = build_config(commit)

      expect(config.content).to eq("rules" => { "no-constructor-vars" => true })
    end

    context "when configuration is linter-flavored JSON format" do
      it "parses the configuration" do
        raw_config = <<~EOS
          {
            "foo": 1, // tslint JSON flavor can have comments
            "bar": 2,
          }
        EOS
        commit = stubbed_commit("config/tslint.json" => raw_config)
        config = build_config(commit)

        expect(config.content).to eq("foo" => 1, "bar" => 2)
      end
    end
  end

  def build_config(commit)
    hound_config = instance_double(
      "HoundConfig",
      commit: commit,
      content: {
        "tslint" => { "enabled": true, "config_file" => "config/tslint.json" },
      },
    )

    Config::Tslint.new(hound_config)
  end
end
