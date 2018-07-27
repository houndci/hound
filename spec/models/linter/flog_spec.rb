require "rails_helper"

RSpec.describe Linter::Flog do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.rb foo.rake) }
    let(:not_lintable_files) { %w(foo.js) }
  end

  describe "#file_included?" do
    context "with test or spec file" do
      it "returns false" do
        spec_file = build_commit_file(filename: "spec/models/user_spec.rb")
        test_file = build_commit_file(filename: "spec/models/user_spec.rb")
        linter = build_linter

        expect(linter.file_included?(spec_file)).to eq false
        expect(linter.file_included?(test_file)).to eq false
      end
    end

    context "with any other ruby file" do
      it "returns true" do
        file1 = build_commit_file(filename: "app/models/user.rb")
        file2 = build_commit_file(filename: "lib/tasks/work.rake")
        file3 = build_commit_file(filename: "app.rb")
        linter = build_linter

        expect(linter.file_included?(file1)).to eq true
        expect(linter.file_included?(file2)).to eq true
        expect(linter.file_included?(file3)).to eq true
      end
    end
  end

  describe "#enabled?" do
    context "when Flog linting is enabled" do
      it "returns true" do
        build = instance_double("Build")
        hound_config = instance_double("HoundConfig", linter_enabled?: true)
        linter = described_class.new(build: build, hound_config: hound_config)

        expect(linter).to be_enabled
      end
    end

    context "when Flog linting is disabled" do
      it "returns false" do
        build = instance_double("Build")
        hound_config = instance_double("HoundConfig", linter_enabled?: false)
        linter = described_class.new(build: build, hound_config: hound_config)

        expect(linter).not_to be_enabled
      end
    end
  end

  describe "#file_review" do
    it "schedules a file review" do
      commit_file = build_commit_file(filename: "lib/foo.rb")
      linter = build_linter
      allow(Resque).to receive(:enqueue)

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
      expect(Resque).to have_received(:enqueue)
    end
  end

  describe "#name" do
    it "is the class name converted to a config-friendly format" do
      linter = build_linter

      expect(linter.name).to eq "flog"
    end
  end
end
