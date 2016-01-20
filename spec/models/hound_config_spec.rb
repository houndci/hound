require "spec_helper"
require "app/models/hound_config"

describe HoundConfig do
  describe "#content" do
    it "returns the content of the .hound.yml file" do
      commit = stubbed_commit(
        ".hound.yml" => <<-EOS.strip_heredoc
          ruby:
            enabled: true
            config_file: config/rubocop.yml
        EOS
      )
      hound_config = HoundConfig.new(commit)

      expect(hound_config.content).to eq(
        "ruby" => {
          "enabled" => true,
          "config_file" => "config/rubocop.yml",
        },
      )
    end
  end

  describe "#enabled_for?" do
    context "given a supported language" do
      it "returns true for all of them" do
        commit = stubbed_commit(".hound.yml" => "")
        hound_config = HoundConfig.new(commit)

        supported_languages =
          HoundConfig::LANGUAGES - HoundConfig::BETA_LANGUAGES
        supported_languages.each do |language|
          expect(hound_config).to be_enabled_for(language)
        end
      end
    end

    context "when the given language is disabled" do
      it "returns false" do
        commit = stubbed_commit(
          ".hound.yml" => <<-EOS.strip_heredoc
            scss:
              enabled: false
          EOS
        )
        hound_config = HoundConfig.new(commit)

        expect(hound_config).not_to be_enabled_for("scss")
      end
    end

    context "when the given language is an alias, and is disabled" do
      it "returns false" do
        commit = stubbed_commit(
          ".hound.yml" => <<-EOS.strip_heredoc
            javascript:
              enabled: false
          EOS
        )
        hound_config = HoundConfig.new(commit)

        expect(hound_config).not_to be_enabled_for("jshint")
      end
    end

    context "when the given language is supported but unconfigured" do
      it "returns true" do
        commit = stubbed_commit(
          ".hound.yml" => <<-EOS.strip_heredoc
            scss:
              config_file: config/.scss_lint.yml
          EOS
        )
        hound_config = HoundConfig.new(commit)

        expect(hound_config).to be_enabled_for("scss")
      end
    end

    context "given a language in beta" do
      context "when the given language is enabled" do
        it "returns true" do
          commit = stubbed_commit(
            ".hound.yml" => <<-EOS.strip_heredoc
              python:
                enabled: true
            EOS
          )
          hound_config = HoundConfig.new(commit)

          expect(hound_config).to be_enabled_for("python")
        end
      end

      context "when the enabled key is capitalized" do
        it "returns true" do
          commit = stubbed_commit(
            ".hound.yml" => <<-EOS.strip_heredoc
              python:
                Enabled: true
            EOS
          )
          hound_config = HoundConfig.new(commit)

          expect(hound_config).to be_enabled_for("python")
        end
      end

      context "when the given language has underscores in it" do
        it "converts them and returns true" do
          commit = stubbed_commit(
            ".hound.yml" => <<-EOS.strip_heredoc
              coffeescript:
                enabled: true
            EOS
          )
          hound_config = HoundConfig.new(commit)

          expect(hound_config).to be_enabled_for("coffee_script")
        end
      end

      context "when the given language is disabled" do
        it "returns false" do
          commit = stubbed_commit(
            ".hound.yml" => <<-EOS.strip_heredoc
              python:
                enabled: false
            EOS
          )
          hound_config = HoundConfig.new(commit)

          expect(hound_config).not_to be_enabled_for("python")
        end
      end
    end
  end

  describe "#fail_on_violations?" do
    context "when the setting is turned on" do
      it "returns true" do
        commit = stubbed_commit(
          ".hound.yml" => <<-EOS.strip_heredoc
            fail_on_violations: true
          EOS
        )
        hound_config = HoundConfig.new(commit)

        expect(hound_config.fail_on_violations?).to eq true
      end
    end

    context "when the setting is turned off" do
      it "returns false" do
        commit = stubbed_commit(
          ".hound.yml" => <<-EOS.strip_heredoc
            fail_on_violations: false
          EOS
        )
        hound_config = HoundConfig.new(commit)

        expect(hound_config.fail_on_violations?).to eq false
      end
    end

    context "when the setting is unconfigured" do
      it "returns false" do
        commit = stubbed_commit(".hound.yml" => "")
        hound_config = HoundConfig.new(commit)

        expect(hound_config.fail_on_violations?).to eq false
      end
    end
  end
end
