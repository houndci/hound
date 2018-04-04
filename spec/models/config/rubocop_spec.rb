require "rails_helper"

describe Config::Rubocop do
  describe "#content" do
    it "dumps the config content to yaml" do
      raw_config = <<~EOS
        Style/Encoding:
          Enabled: true
      EOS
      config = build_config(raw_config)

      expect(config.content.to_yaml).to eq <<~YML
        ---
        Style/Encoding:
          Enabled: true
      YML
    end

    context "when the hound config is a legacy config" do
      it "returns the HoundConfig's content as a hash" do
        hound_config = instance_double(
          "HoundConfig",
          content: { "LineLength" => { "Max" => 90 } },
        )
        config = Config::Rubocop.new(hound_config)

        expect(config.content).to eq("LineLength" => { "Max" => 90 })
      end
    end

    context "when the hound config is not a legacy config" do
      it "returns the content from GitHub as a hash" do
        raw_config = '{ "LineLength": { "Max": 90 } }'
        config = build_config(raw_config)

        expect(config.content).to eq("LineLength" => { "Max" => 90 })
      end

      context "and an owner is present" do
        it "returns the config merged with the owner's config as a hash" do
          raw_config = '{ "LineLength": { "Max": 90 } }'
          owner_config = { "Metrics/ClassLength" => { "Max" => 100 } }
          owner = instance_double("Owner", config_content: owner_config)
          config = build_config(raw_config, owner)

          expect(config.content).to eq(
            "LineLength" => { "Max" => 90 },
            "Metrics/ClassLength" => { "Max" => 100 },
          )
        end
      end
    end

    context "when the configuration uses `inherit_from`" do
      it "returns the merged configuration using `inherit_from`" do
        repo_config = <<~EOS
          inherit_from:
            - config/base.yml
            - config/overrides.yml
          Style/StringLiterals:
            EnforcedStyle: single_quotes
        EOS
        base = <<~EOS
          LineLength:
            Max: 40
        EOS
        overrides = <<~EOS
          Style/HashSyntax:
            EnforcedStyle: hash_rockets
        EOS
        commit = stub_commit(
          "config/rubocop.yml" => repo_config,
          "config/base.yml" => base,
          "config/overrides.yml" => overrides,
        )
        owner_config = {
          "Style/StringLiterals" => {
            "EnforcedStyle" => "double_quotes",
          },
          "Style/HashSyntax" => {
            "EnforcedStyle" => "ruby19",
          },
        }
        owner = instance_double("Owner", config_content: owner_config)
        hound_config = build_hound_config(commit, "config/rubocop.yml")
        config = Config::Rubocop.new(hound_config, owner: owner)

        expect(config.content).to eq(
          "LineLength" => { "Max" => 40 },
          "Style/HashSyntax" => { "EnforcedStyle" => "hash_rockets" },
          "Style/StringLiterals" => { "EnforcedStyle" => "single_quotes" },
        )
      end

      context "with an empty `inherit_from`" do
        it "returns the merged configuration using `inherit_from`" do
          rubocop = <<~EOS
            inherit_from: config/rubocop_todo.yml
            Style/Encoding:
              Enabled: true
          EOS
          rubocop_todo = "# this is an empty file"
          commit = stub_commit(
            "config/rubocop.yml" => rubocop,
            "config/rubocop_todo.yml" => rubocop_todo,
          )
          hound_config = build_hound_config(commit, "config/rubocop.yml")
          config = described_class.new(hound_config)

          expect(config.content).to eq(
            "Style/Encoding" => { "Enabled" => true },
          )
        end
      end

      context "with invalid `inherit_from` content" do
        it "raises a parser error" do
          rubocop = "inherit_from: config/rubocop_todo.yml"
          rubocop_todo = "foo: bar: "
          commit = stub_commit(
            "config/rubocop.yml" => rubocop,
            "config/rubocop_todo.yml" => rubocop_todo,
          )
          hound_config = build_hound_config(commit, "config/rubocop.yml")
          config = described_class.new(hound_config)

          expect { config.content }.to raise_error(Config::ParserError)
        end
      end
    end

    context "with serialized symbols in yaml" do
      it "returns the config" do
        raw_config = <<~EOS
          Style/InverseMethods:
            Enabled: true
            :any?: :none?
        EOS
        config = build_config(raw_config)

        expect(config.content).to eq(
          "Style/InverseMethods" => {
            "Enabled" => true,
            any?: :none?,
          },
        )
      end
    end

    context "when the given content is invalid" do
      context "when the result is not a hash" do
        it "raises a type exception" do
          config = build_config("[]")

          expect { config.content }.to raise_error(
            Config::ParserError,
            "config/linter-config.any format is invalid",
          )
        end
      end

      context "when the content is invalid yaml" do
        it "raises an exception" do
          raw_config = <<~EOS
            ruby: !ruby/object
              ;foo:
          EOS
          config = build_config(raw_config)

          expect { config.content }.to raise_error(Config::ParserError)
        end
      end
    end
  end
end
