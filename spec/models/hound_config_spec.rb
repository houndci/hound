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
      context "with empty Hound config" do
        it "returns false for all of them" do
          commit = stubbed_commit(".hound.yml" => "")
          hound_config = HoundConfig.new(commit)

          HoundConfig::LINTERS.each do |language|
            expect(hound_config).not_to be_enabled_for(language)
          end
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

    context "when the given language is configured" do
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

    context "when the given language is not explicitly enabled, but configured" do
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

    context "when the given language is disabled, but configured" do
      it "returns false" do
        commit = stubbed_commit(
          ".hound.yml" => <<-EOS.strip_heredoc
            scss:
              enabled: false
              config_file: config/.scss_lint.yml
          EOS
        )
        hound_config = HoundConfig.new(commit)

        expect(hound_config).not_to be_enabled_for("scss")
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
