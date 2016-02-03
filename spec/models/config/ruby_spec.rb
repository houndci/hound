require "spec_helper"
require "app/models/config/base"
require "app/models/config/ruby"
require "app/models/hound_config"
require "app/models/config/parser"
require "app/models/config/parser_error"

describe Config::Ruby do
  describe "#content" do
    context "when the hound config is a legacy config" do
      it "returns the HoundConfig's content as a hash" do
        hound_config = double(
          "HoundConfig",
          content: { "LineLength" => { "Max" => 90 } },
        )
        config = Config::Ruby.new(hound_config, "ruby")

        expect(config.content).to eq("LineLength" => { "Max" => 90 })
      end
    end

    context "when the hound config is not a legacy config" do
      it "returns the content from GitHub as a hash" do
        commit = stubbed_commit(
          "config/rubocop.yml" => '{ "LineLength": { "Max": 90 } }',
        )
        config = build_config(commit)

        expect(config.content).to eq("LineLength" => { "Max" => 90 })
      end
    end

    it "dumps the config content to yaml" do
      rubocop = <<-EOS.strip_heredoc
        Style/Encoding:
          Enabled: true
      EOS
      commit = stubbed_commit(
        "config/rubocop.yml" => rubocop,
      )

      config = build_config(commit)

      expect(config.content.to_yaml).to eq <<-YML.strip_heredoc
        ---
        Style/Encoding:
          Enabled: true
      YML
    end
  end

  context "when the configuration uses `inherit_from`" do
    it "returns the merged configuration using `inherit_from`" do
      rubocop = <<-EOS.strip_heredoc
        inherit_from:
          - config/base.yml
          - config/overrides.yml
        Style/Encoding:
          Enabled: true
      EOS
      base = <<-EOS.strip_heredoc
        LineLength:
          Max: 40
      EOS
      overrides = <<-EOS.strip_heredoc
        Style/HashSyntax:
          EnforcedStyle: hash_rockets
        Style/Encoding:
          Enabled: false
      EOS
      commit = stubbed_commit(
        "config/rubocop.yml" => rubocop,
        "config/base.yml" => base,
        "config/overrides.yml" => overrides,
      )
      config = build_config(commit)

      expect(config.content).to eq(
        "LineLength" => { "Max" => 40 },
        "Style/HashSyntax" => { "EnforcedStyle" => "hash_rockets" },
        "Style/Encoding" => { "Enabled" => true },
      )
    end

    context "with an empty `inherit_from`" do
      it "returns the merged configuration using `inherit_from`" do
        rubocop = <<-EOS.strip_heredoc
          inherit_from: config/rubocop_todo.yml
          Style/Encoding:
            Enabled: true
        EOS
        rubocop_todo = <<-EOS.strip_heredoc
          # this is an empty file
        EOS
        commit = stubbed_commit(
          "config/rubocop.yml" => rubocop,
          "config/rubocop_todo.yml" => rubocop_todo,
        )
        config = build_config(commit)

        expect(config.content).to eq(
          "Style/Encoding" => { "Enabled" => true },
        )
      end
    end
  end

  context "when the given content is invalid" do
    context "when the result is not a hash" do
      it "raises a type exception" do
        commit = stubbed_commit(
          "config/rubocop.yml" => <<-EOS.strip_heredoc
            !
          EOS
        )
        config = build_config(commit)

        expect { config.content }.to raise_error(
          Config::ParserError,
          %r(`config/rubocop.yml` must be a Hash),
        )
      end
    end

    context "when the content is invalid yaml" do
      it "raises an exception" do
        commit = stubbed_commit(
          "config/rubocop.yml" => <<-EOS.strip_heredoc
            ruby: !ruby/object
              ;foo:
          EOS
        )
        config = build_config(commit)

        expect { config.content }.to raise_error(
          Config::ParserError,
          /Tried to load unspecified class: Object/,
        )
      end
    end
  end

  def build_config(commit)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "ruby" => {
          "config_file" => "config/rubocop.yml",
        },
      },
    )

    Config::Ruby.new(hound_config, "ruby")
  end
end
