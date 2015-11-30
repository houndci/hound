require "spec_helper"
require "app/models/config/base"
require "app/models/config/java_script"
require "app/models/config/parser_error"

describe Config::JavaScript do
  describe "#content" do
    context "with a modern javascript config" do
      it "returns the content from GitHub as a hash" do
        commit = stubbed_commit(
          "config/jshint.json" => '{ "trailing": true }',
        )
        config = build_config(commit)

        result = config.content

        expect(result).to eq("trailing" => true)
      end
    end

    context "with a legacy javascript config" do
      it "returns the content from GitHub as a hash" do
        commit = stubbed_commit(
          "config/jshint.json" => '{ "trailing": true }',
        )
        config = build_config(commit)

        result = config.content

        expect(result).to eq("trailing" => true)
      end
    end

    context "when the given content is invalid" do
      context "when the result is not a hash" do
        it "raises a type exception" do
          commit = stubbed_commit(
            "config/jshint.json" => <<-EOS.strip_heredoc
              []
            EOS
          )
          config = build_config(commit)

          expect { config.content }.to raise_error(
            Config::ParserError,
            %r(`config/jshint.json` must be a Hash),
          )
        end
      end

      context "when the content is invalid json" do
        it "raises an exception" do
          commit = stubbed_commit(
            "config/jshint.json" => <<-EOS.strip_heredoc
              XXX
            EOS
          )
          config = build_config(commit)

          expect { config.content }.to raise_error(
            Config::ParserError,
            /unexpected token at 'XXX\n'/,
          )
        end
      end
    end
  end

  describe "#excluded_files" do
    context "when no ignore file is configured" do
      it "returns the default paths" do
        commit = stubbed_commit(".jshintignore" => nil)
        config = build_config(commit)

        expect(config.excluded_files).to eq ["vendor/*"]
      end
    end

    context "when an ignore file is configured" do
      it "returns the paths specified in the file" do
        commit = stubbed_commit(
          ".jshintignore" => <<-EOS.strip_heredoc
              app/javascript/vendor/*
          EOS
        )
        config = build_config(commit)

        expect(config.excluded_files).to eq ["app/javascript/vendor/*"]
      end
    end
  end

  def build_config(commit)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "javascript" => {
          "enabled" => true,
          "config_file" => "config/jshint.json",
          "ignore_file" => ".jshintignore",
        },
      },
    )
    Config::JavaScript.new(hound_config, "javascript")
  end
end
