require "spec_helper"
require "app/models/linter/base"
require "app/models/config/base"
require "app/models/config/unsupported"
require "app/services/build_config"

module Linter
  class Test < Base
    FILE_REGEXP = /.+\.yes\z/
  end
end

describe Linter::Test do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.yes) }
    let(:not_lintable_files) { %w(foo.no bar.nope) }
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
        hound_config = instance_double("HoundConfig", linter_enabled?: true)
        linter = build_linter(hound_config: hound_config)

        expect(linter).to be_enabled
      end
    end

    context "when the hound config is disabled for the given language" do
      it "returns false" do
        hound_config = instance_double("HoundConfig", linter_enabled?: false)
        linter = build_linter(hound_config: hound_config)

        expect(linter).not_to be_enabled
      end
    end
  end

  def build_linter(options = {})
    default_options = {
      hound_config: double("HoundConfig", enabled_for?: false),
      build: double("Build", repo: double("Repo")),
    }

    Linter::Test.new(default_options.merge(options))
  end
end
