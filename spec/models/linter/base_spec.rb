require "spec_helper"
require "app/models/linter/base"

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
      linter = Linter::Test.new(
        hound_config: double,
        build: double,
        repository_owner_name: "foo",
      )

      expect(linter.file_included?(double)).to eq true
    end
  end

  describe "#enabled?" do
    context "when the hound config is enabled for the given language" do
      it "returns true" do
        hound_config = double("HoundConfig", enabled_for?: true)
        linter = Linter::Test.new(
          hound_config: hound_config,
          build: double,
          repository_owner_name: "foo",
        )

        expect(linter.enabled?).to eq true
      end
    end

    context "when the hound config is disabled for the given language" do
      it "returns false" do
        hound_config = double("HoundConfig", enabled_for?: false)
        linter = Linter::Test.new(
          hound_config: hound_config,
          build: double,
          repository_owner_name: "foo",
        )

        expect(linter.enabled?).to eq false
      end
    end

    context "when the hound config is disabled for the given language" do
      it "returns false" do
        hound_config = double("HoundConfig", enabled_for?: false)
        linter = Linter::Test.new(
          hound_config: hound_config,
          build: double,
          repository_owner_name: "foo",
        )

        expect(linter.enabled?).to eq false
      end
    end
  end
end
