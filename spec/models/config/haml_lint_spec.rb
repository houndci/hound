require "spec_helper"
require "app/models/config/base"
require "app/models/config/haml_lint"
require "app/models/config/parser"
require "app/models/config/parser_error"
require "app/models/config/serializer"

describe Config::HamlLint do
  describe "#content" do
    context "when the given content is valid" do
      it "returns the content from GitHub as a hash" do
        commit = stubbed_commit(
          "config/haml.yml" => <<-EOS.strip_heredoc
            linters:
              AltText:
                enabled: true
          EOS
        )
        config = build_config(commit)

        expect(config.content).to eq(
          "linters" => { "AltText" => { "enabled" => true } },
        )
      end
    end

    context "when the given content is invalid" do
      context "when the result is not a hash" do
        it "raises a type exception" do
          commit = stubbed_commit(
            "config/haml.yml" => <<-EOS.strip_heredoc
              !
            EOS
          )
          config = build_config(commit)

          expect { config.content }.to raise_error(
            Config::ParserError,
            %r("config/haml\.yml" must be a Hash),
          )
        end
      end

      context "when the content is invalid yaml" do
        it "raises an exception" do
          commit = stubbed_commit(
            "config/haml.yml" => <<-EOS.strip_heredoc
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
  end

  describe "#linter_names" do
    it "returns the names that the linter is accessible under" do
      commit = stubbed_commit({})
      config = build_config(commit)

      expect(config.linter_names).to match_array %w(haml haml-lint)
    end
  end

  def build_config(commit)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "haml-lint" => {
          "enabled" => true,
          "config_file" => "config/haml.yml",
        },
      },
    )
    Config::HamlLint.new(hound_config)
  end
end
