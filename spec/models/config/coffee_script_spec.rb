require "spec_helper"
require "app/models/config/base"
require "app/models/config/coffee_script"
require "app/models/config/parser"
require "app/models/config/parser_error"
require "app/models/config_content"
require "app/models/missing_owner"
require "app/services/build_config"

describe Config::CoffeeScript do
  describe "#content" do
    context "with a modern coffeescript config" do
      it "returns the content from GitHub as a hash" do
        commit = stubbed_commit(
          "config/coffeescript.json" => <<-EOS.strip_heredoc
            { "arrow_spacing": { "level": "error" } }
          EOS
        )
        config = build_config(commit)
        owner_config = instance_double("Config::CoffeeScript", content: {})
        allow(BuildConfig).to receive(:for).and_return(owner_config)

        result = config.content

        expect(result).to eq(
          "arrow_spacing" => { "level" => "error" },
        )
      end
    end

    context "with a legacy coffeescript config" do
      it "returns the content from GitHub as a hash" do
        commit = stubbed_commit(
          "config/coffeescript.json" => <<-EOS.strip_heredoc
            { "arrow_spacing": { "level": "error" } }
          EOS
        )
        config = build_config(commit)
        owner_config = instance_double("Config::CoffeeScript", content: {})
        allow(BuildConfig).to receive(:for).and_return(owner_config)

        result = config.content

        expect(result).to eq(
          "arrow_spacing" => { "level" => "error" },
        )
      end
    end

    context "when the config file is invalid" do
      it "raises an exception" do
        commit = stubbed_commit(
          "config/coffeescript.json" => <<-EOS.strip_heredoc
            { invalid_json: [ }
          EOS
        )
        config = build_config(commit)
        owner_config = instance_double("Config::CoffeeScript", content: {})
        allow(BuildConfig).to receive(:for).and_return(owner_config)

        expect { config.content }.to raise_error(Config::ParserError)
      end
    end
  end

  def build_config(commit)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "coffee_script" => {
          "enabled" => true,
          "config_file" => "config/coffeescript.json",
        },
      },
    )
    Config::CoffeeScript.new(hound_config)
  end
end
