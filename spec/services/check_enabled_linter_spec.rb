require "spec_helper"
require "app/services/check_enabled_linter"

describe CheckEnabledLinter do
  describe ".run" do
    context "when the hound config is enabled for the given language" do
      it "returns true" do
        hound_config = double("HoundConfig", linter_enabled?: true)
        config = double(
          "Config",
          linter_name: ["ruby"],
          hound_config: hound_config,
        )

        result = CheckEnabledLinter.run(config)

        expect(result).to eq true
      end
    end

    context "when the hound config is disabled for the given language" do
      it "returns false" do
        hound_config = double("HoundConfig", linter_enabled?: false)
        config = double(
          "Config",
          linter_name: ["ruby"],
          hound_config: hound_config,
        )

        result = CheckEnabledLinter.run(config)

        expect(result).to eq false
      end
    end
  end
end
