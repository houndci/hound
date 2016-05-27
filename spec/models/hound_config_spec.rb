require "spec_helper"
require "app/models/linter/base"
require "app/models/linter/coffee_script"
require "app/models/linter/eslint"
require "app/models/linter/go"
require "app/models/linter/haml"
require "app/models/linter/jscs"
require "app/models/linter/jshint"
require "app/models/linter/remark"
require "app/models/linter/python"
require "app/models/linter/ruby"
require "app/models/linter/scss"
require "app/models/linter/swift"
require "app/models/linter/collection"
require "app/models/config/parser"
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

  describe "#disabled_for?" do
    context "given a language that is disabled in the config file" do
      context "given that language is not a default" do
        it "returns true" do
          commit = stubbed_commit(
            ".hound.yml" => <<-EOS.strip_heredoc
              remark:
                enabled: false
            EOS
          )
          hound_config = HoundConfig.new(commit)

          expect(hound_config).to be_disabled_for("remark")
        end
      end
    end

    context "given a language that isn't in the config file" do
      it "returns false" do
        commit = stubbed_commit(".hound.yml" => "")
        hound_config = HoundConfig.new(commit)

        expect(hound_config).not_to be_disabled_for("remark")
      end
    end

    context "given a language that is enabled in the config file" do
      it "returns false" do
        commit = stubbed_commit(
          ".hound.yml" => <<-EOS.strip_heredoc
            remark:
              enabled: true
          EOS
        )
        hound_config = HoundConfig.new(commit)

        expect(hound_config).not_to be_disabled_for("remark")
      end
    end
  end

  describe "#enabled_for?" do
    context "given a language that is enabled in the config file" do
      it "returns true" do
        commit = stubbed_commit(
          ".hound.yml" => <<-EOS.strip_heredoc
            remark:
              enabled: true
          EOS
        )
        hound_config = HoundConfig.new(commit)

        expect(hound_config).to be_enabled_for("remark")
      end
    end

    context "given a language that isn't in the config file" do
      context "given that language is not a default" do
        it "returns false" do
          commit = stubbed_commit(".hound.yml" => "")
          hound_config = HoundConfig.new(commit)

          expect(hound_config).not_to be_enabled_for("remark")
        end
      end

      context "given that language is a default" do
        it "returns true for all of them" do
          commit = stubbed_commit(".hound.yml" => "")
          hound_config = HoundConfig.new(commit)

          default_linters = HoundConfig::DEFAULT_LINTERS
          default_linters.each do |linter|
            expect(hound_config).to be_enabled_for(linter)
          end
        end
      end

      context "given that language is in beta" do
        it "returns false for all of them" do
          commit = stubbed_commit(".hound.yml" => "")
          hound_config = HoundConfig.new(commit)

          default_linters = HoundConfig::BETA_LINTERS
          default_linters.each do |linter|
            expect(hound_config).not_to be_enabled_for(linter)
          end
        end
      end
    end

    context "given a language that is disabled in the config file" do
      context "given that language is not a default" do
        it "returns false" do
          commit = stubbed_commit(".hound.yml" => "")
          hound_config = HoundConfig.new(commit)

          expect(hound_config).not_to be_enabled_for("remark")
        end
      end

      context "given that language is a default" do
        it "returns true for all of them" do
          commit = stubbed_commit(".hound.yml" => "")
          hound_config = HoundConfig.new(commit)

          default_linters = HoundConfig::DEFAULT_LINTERS
          default_linters.each do |linter|
            expect(hound_config).to be_enabled_for(linter)
          end
        end
      end
    end

    context "given an unsupported language" do
      it "returns false" do
        commit = stubbed_commit(".hound.yml" => "")
        hound_config = HoundConfig.new(commit)
        unsupported_linter = "some_random_linter"

        expect(hound_config).not_to be_enabled_for(unsupported_linter)
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
