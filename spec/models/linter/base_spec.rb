require "spec_helper"
require "app/models/linter/base"
require "app/services/check_enabled_linter"
require "app/models/config_builder"
require "app/models/config/base"
require "app/models/config/unsupported"

module Linter
  class Test < Base
    FILE_REGEXP = /.+\.yes\z/
  end
end

describe Linter::Base do
  describe ".can_lint?" do
    it "uses the FILE_REGEXP to determine the match" do
      yes_lint = Linter::Test.can_lint?("foo.yes")
      no_lint = Linter::Test.can_lint?("foo.no")

      expect(yes_lint).to eq true
      expect(no_lint).to eq false
    end
  end

  describe "#file_included?" do
    it "returns true" do
      linter = build_linter

      expect(linter.file_included?(double)).to eq true
    end
  end

  describe "#enabled?" do
    context "when the hound config is enabled for the given language" do
      it "returns true" do
        allow(CheckEnabledLinter).to receive(:run).and_return(true)
        linter = build_linter

        expect(linter.enabled?).to eq true
        expect(CheckEnabledLinter).to have_received(:run)
      end
    end

    context "when the hound config is disabled for the given language" do
      it "returns false" do
        allow(CheckEnabledLinter).to receive(:run).and_return(false)
        linter = build_linter

        expect(linter.enabled?).to eq false
        expect(CheckEnabledLinter).to have_received(:run)
      end
    end
  end

  def build_linter(options = {})
    default_options = {
      hound_config: double("HoundConfig", enabled_for?: false),
      build: double("Build", repo: double("Repo")),
      repository_owner_name: "foo",
    }

    Linter::Test.new(default_options.merge(options))
  end
end
