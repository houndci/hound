require "rails_helper"

module Linter
  RSpec.describe Flog do
    describe ".can_lint?" do
      context "when given a '.rb' file" do
        it "is true" do
          expect(Flog.can_lint?("foo.rb")).to be(true)
        end
      end

      context "when given a '.rake' file" do
        it "is true" do
          expect(Flog.can_lint?("foo.rake")).to be(true)
        end
      end

      context "when given a non-Ruby file" do
        it "is false" do
          expect(Flog.can_lint?("foo.js")).to be(false)
        end
      end
    end

    describe "#enabled?" do
      context "when Flog linting is enabled" do
        it "is true" do
          build = instance_double("Build")
          hound_config = instance_double("HoundConfig", linter_enabled?: true)
          linter = Flog.new(build: build, hound_config: hound_config)

          expect(linter).to be_enabled
        end
      end
    end

    describe "#file_included?" do
      it "is always true" do
        build = instance_double("Build")
        hound_config = instance_double("HoundConfig", linter_enabled?: true)
        linter = Flog.new(build: build, hound_config: hound_config)

        expect(linter.file_included?).to be(true)
      end
    end

    describe "#file_review" do
      it "is a new file review" do
        repo = instance_double("Repo", owner: nil)
        build = instance_double(
          "Build",
          commit_sha: "somesha",
          pull_request_number: 123,
          repo: repo,
        )
        commit_file = instance_double(
          "CommitFile",
          content: "code",
          filename: "lib/ruby.rb",
          patch: "patch",
        )
        file_review = instance_double("FileReview")
        hound_config = instance_double("HoundConfig")
        missing_owner = instance_double("MissingOwner")
        allow(FileReview).to receive(:create!).and_return(file_review)
        allow(MissingOwner).to receive(:new).and_return(missing_owner)
        allow(Resque).to receive(:enqueue)
        linter = Flog.new(build: build, hound_config: hound_config)

        expect(linter.file_review(commit_file)).to eq file_review
        expect(Resque).to have_received(:enqueue)
      end
    end

    describe "#name" do
      it "is the class name converted to a config-friendly format" do
        build = instance_double("Build")
        hound_config = instance_double("HoundConfig")
        linter = Flog.new(build: build, hound_config: hound_config)

        expect(linter.name).to eq "flog"
      end
    end
  end
end
