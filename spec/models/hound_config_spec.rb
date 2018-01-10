require "app/models/config/parser"
require "app/services/normalize_config"
require "app/services/resolve_config_aliases"
require "app/services/resolve_config_conflicts"

Dir["app/models/linter/*.rb"].each { |f| require f }
require "app/models/hound_config"

describe HoundConfig do
  describe "#content" do
    it "returns the contents of .hound.yml, merged with the default config" do
      commit = stub_commit(
        ".hound.yml" => <<~EOS
          ruby:
            config_file: config/rubocop.yml
        EOS
      )
      hound_config = HoundConfig.new(commit)

      expect(hound_config.content["ruby"]).to eq(
        "enabled" => true,
        "config_file" => "config/rubocop.yml",
      )
    end
  end

  describe "#linter_enabled?" do
    context "given a supported language" do
      it "returns true for all of them" do
        commit = stub_commit(".hound.yml" => "")
        hound_config = HoundConfig.new(commit)

        enabled_by_default = HoundConfig::LINTERS.
          select { |_, config| config[:default] }
        Hash(enabled_by_default).keys.each do |linter_name|
          expect(hound_config).
            to be_enabled_for(linter_name.name.demodulize.underscore)
        end
      end
    end

    context "when the given language is disabled" do
      it "returns false" do
        commit = stub_commit(
          ".hound.yml" => <<~EOS
            ruby:
              enabled: false
          EOS
        )
        hound_config = HoundConfig.new(commit)

        expect(hound_config).not_to be_enabled_for("ruby")
      end
    end

    context "when the given language is enabled" do
      it "returns true" do
        commit = stub_commit(
          ".hound.yml" => <<~EOS
            remark:
              enabled: true
          EOS
        )
        hound_config = HoundConfig.new(commit)

        expect(hound_config).to be_enabled_for("remark")
      end
    end

    context "when the given language is an alias, and is disabled" do
      it "returns false" do
        commit = stub_commit(
          ".hound.yml" => <<~EOS
            java_script:
              enabled: false
          EOS
        )
        hound_config = HoundConfig.new(commit)

        expect(hound_config).not_to be_enabled_for("jshint")
      end
    end

    context "when the given language conflicts with an enabled linter" do
      it "returns false" do
        stub_const("ResolveConfigConflicts::CONFLICTS", "eslint" => "jshint")
        commit = stub_commit(
          ".hound.yml" => <<~EOS
            eslint:
              enabled: true
          EOS
        )
        hound_config = HoundConfig.new(commit)

        expect(hound_config).not_to be_enabled_for("jshint")
        expect(hound_config).to be_enabled_for("eslint")
      end
    end

    context "given an unsupported language" do
      it "returns false" do
        commit = stub_commit(".hound.yml" => "")
        hound_config = HoundConfig.new(commit)
        unsupported_linter = "some_random_linter"

        expect(hound_config).not_to be_enabled_for(unsupported_linter)
      end
    end

    context "when the enabled key is capitalized" do
      it "returns true" do
        commit = stub_commit(
          ".hound.yml" => <<~EOS
            flake8:
              Enabled: true
          EOS
        )
        hound_config = HoundConfig.new(commit)

        expect(hound_config).to be_enabled_for("flake8")
      end
    end

    context "when the given language has underscores in it" do
      it "converts them and returns true" do
        commit = stub_commit(
          ".hound.yml" => <<~EOS
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
        commit = stub_commit(
          ".hound.yml" => <<~EOS
            fail_on_violations: true
          EOS
        )
        hound_config = HoundConfig.new(commit)

        expect(hound_config.fail_on_violations?).to eq true
      end
    end

    context "when the setting is turned off" do
      it "returns false" do
        commit = stub_commit(
          ".hound.yml" => <<~EOS
            fail_on_violations: false
          EOS
        )
        hound_config = HoundConfig.new(commit)

        expect(hound_config.fail_on_violations?).to eq false
      end
    end

    context "when the setting is unconfigured" do
      it "returns false" do
        commit = stub_commit(".hound.yml" => "")
        hound_config = HoundConfig.new(commit)

        expect(hound_config.fail_on_violations?).to eq false
      end
    end
  end

  def be_enabled_for(linter_name)
    be_linter_enabled(linter_name)
  end
end
