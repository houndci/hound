require "rails_helper"

describe Linter::Collection do
  describe ".for" do
    context "when the given filename maps to a linter" do
      it "instantiates the collection with the matching linters" do
        hound_config = double("HoundConfig")
        build = double("Build")
        pull_request = double(
          "PullRequest",
          head_commit: "HeadCommit",
          repository_owner_name: "thoughtbot",
        )
        collection = Linter::Collection.for(
          filename: "bank.rb",
          hound_config: hound_config,
          build: build,
          repository_owner_name: pull_request.repository_owner_name,
        )

        expect(collection.linters.sample).to be_a Linter::Ruby
      end
    end

    context "when the given filename does not map to a linter" do
      it "instantiates the collection with the unsupported linter" do
        hound_config = double("HoundConfig")
        build = double("Build")
        pull_request = double(
          "PullRequest",
          head_commit: "HeadCommit",
          repository_owner_name: "thoughtbot",
        )
        collection = Linter::Collection.for(
          filename: "bank.f",
          hound_config: hound_config,
          build: build,
          repository_owner_name: pull_request.repository_owner_name,
        )

        expect(collection.linters.sample).to be_a Linter::Unsupported
      end
    end
  end

  describe "#file_review" do
    context "when the linters are enabled and has given file included" do
      it "calls `file_review` on the linters" do
        element_a = double(
          "ElementA",
          enabled?: true,
          file_included?: true,
          file_review: true,
        )
        element_b = double(
          "ElementB",
          enabled?: false,
          file_included?: true,
          file_review: true,
        )
        element_c = double(
          "ElementC",
          enabled?: true,
          file_included?: true,
          file_review: true,
        )
        elements = [element_a, element_b, element_c]
        commit_file = double("CommitFile")
        collection = Linter::Collection.new(elements)

        collection.file_review(commit_file)

        expect(element_a).to have_received(:file_review).with(commit_file)
        expect(element_b).not_to have_received(:file_review)
        expect(element_c).to have_received(:file_review).with(commit_file)
      end
    end

    context "when the linters are disabled and has the file included" do
      it "does nothing" do
        element_a = double(
          "ElementA",
          enabled?: false,
          file_included?: false,
          file_review: true,
        )
        element_b = double(
          "ElementB",
          enabled?: true,
          file_included?: false,
          file_review: true,
        )
        element_c = double(
          "ElementC",
          enabled?: false,
          file_included?: true,
          file_review: true,
        )
        elements = [element_a, element_b, element_c]
        commit_file = double("CommitFile")
        collection = Linter::Collection.new(elements)

        collection.file_review(commit_file)

        expect(element_a).not_to have_received(:file_review)
        expect(element_b).not_to have_received(:file_review)
        expect(element_c).not_to have_received(:file_review)
      end
    end
  end
end
