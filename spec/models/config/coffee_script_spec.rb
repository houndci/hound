require "spec_helper"
require "app/models/config/base"
require "app/models/config/parser_error"
require "app/models/config/coffee_script"

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
            invalid_json
          EOS
        )
        config = build_config(commit)

        expect { config.content }.to raise_error(
          Config::ParserError,
          /unexpected token at 'invalid_json\n'/,
        )
      end
    end
  end

  def build_config(commit)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "coffeescript" => {
          "enabled" => true,
          "config_file" => "config/coffeescript.json",
        },
      },
    )
    Config::CoffeeScript.new(hound_config, "coffeescript")
  end
end
