require "spec_helper"
require "app/models/config/base"
require "app/models/config/ruby"
require "app/models/config/unsupported"
require "app/models/missing_owner"
require "app/services/build_config"

describe BuildConfig do
  describe ".call" do
    context "when there is matching config class for the given name" do
      it "returns the matching config" do
        config = BuildConfig.call(
          hound_config: double,
          name: "ruby",
          owner: instance_double("Owner"),
        )

        expect(config).to be_a(Config::Ruby)
      end
    end

    context "when there is not matching config class for the given name" do
      it "returns the unsupported config" do
        config = BuildConfig.call(
          hound_config: double,
          name: "non-existent-config",
          owner: instance_double("Owner"),
        )

        expect(config).to be_a(Config::Unsupported)
      end
    end
  end
end
