require "spec_helper"
require "app/services/check_enabled_linter"

describe CheckEnabledLinter do
  describe ".run" do
    context "when the hound config is enabled for the given language" do
      it "returns true" do
        hound_config = double(
          "HoundConfig",
          disabled_for?: false,
          enabled_for?: true,
        )
        config = double(
          "Config",
          linter_names: ["ruby"],
          hound_config: hound_config,
        )

        result = CheckEnabledLinter.run(config)

        expect(result).to eq true
      end
    end

    context "when the hound config is disabled for the given language" do
      it "returns false" do
        hound_config = double("HoundConfig", disabled_for?: true)
        config = double(
          "Config",
          linter_names: ["ruby"],
          hound_config: hound_config,
        )

        result = CheckEnabledLinter.run(config)

        expect(result).to eq false
      end
    end

    context "when the hound config is disabled for an alias" do
      it "returns false" do
        hound_config = double("HoundConfig", disabled_for?: false)
        allow(hound_config).to receive(:disabled_for?).with("javascript").
          and_return(true)
        config = double(
          "Config",
          linter_names: ["javascript", "jshint"],
          hound_config: hound_config,
        )

        result = CheckEnabledLinter.run(config)

        expect(result).to eq false
      end
    end

    context "when the hound config does not contain the given language" do
      context "when the given language is default" do
        it "returns true" do
          hound_config = double(
            "HoundConfig",
            enabled_for?: false,
            disabled_for?: false,
          )
          config = double(
            "Config",
            linter_names: CheckEnabledLinter::DEFAULT_LINTERS,
            hound_config: hound_config,
          )

          result = CheckEnabledLinter.run(config)

          expect(result).to eq true
        end
      end

      context "when the given language is in beta" do
        it "returns false" do
          hound_config = double(
            "HoundConfig",
            enabled_for?: false,
            disabled_for?: false,
          )
          config = double(
            "Config",
            linter_names: CheckEnabledLinter::BETA_LINTERS,
            hound_config: hound_config,
          )

          result = CheckEnabledLinter.run(config)

          expect(result).to eq false
        end
      end
    end
  end
end
