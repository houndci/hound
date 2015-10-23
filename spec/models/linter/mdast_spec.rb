require "rails_helper"

describe Linter::Mdast do
  describe ".can_lint?" do
    context "given an .md file" do
      it "returns true" do
        result = Linter::Mdast.can_lint?("foo.md")

        expect(result).to eq true
      end
    end

    context "given an .markdown file" do
      it "returns true" do
        result = Linter::Mdast.can_lint?("foo.markdown")

        expect(result).to eq true
      end
    end

    context "given a non-markdown file" do
      it "returns false" do
        result = Linter::Mdast.can_lint?("foo.txt")

        expect(result).to eq false
      end
    end
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      commit_file = build_commit_file(filename: "lib/a.md")
      linter = build_linter

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      stub_mdast_config(content: "config")
      commit_file = build_commit_file(filename: "lib/a.md")
      allow(Resque).to receive(:enqueue)
      linter = build_linter(build)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        MdastReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "config",
      )
    end
  end

  def stub_mdast_config(content: "")
    stubbed_mdast_config = double("MdastConfig", content: content)
    allow(Config::Mdast).to receive(:new).and_return(stubbed_mdast_config)

    stubbed_mdast_config
  end

  def raw_hound_config
    <<-EOS.strip_heredoc
      mdast:
        enabled: true
        config_file: config/.mdastrc
    EOS
  end
end
