require "rails_helper"

describe Linter::Remark do
  describe ".can_lint?" do
    context "given an .md file" do
      it "returns true" do
        result = Linter::Remark.can_lint?("foo.md")

        expect(result).to eq true
      end
    end

    context "given an .markdown file" do
      it "returns true" do
        result = Linter::Remark.can_lint?("foo.markdown")

        expect(result).to eq true
      end
    end

    context "given a non-markdown file" do
      it "returns false" do
        result = Linter::Remark.can_lint?("foo.txt")

        expect(result).to eq false
      end
    end
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      commit_file = build_commit_file(filename: "lib/a.md")
      linter = build_linter
      stub_owner_hound_config

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      stub_remark_config(content: {})
      stub_owner_hound_config
      commit_file = build_commit_file(filename: "lib/a.md")
      allow(Resque).to receive(:enqueue)
      linter = build_linter(build)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        RemarkReviewJob,
        commit_sha: build.commit_sha,
        config: "{}",
        content: commit_file.content,
        filename: commit_file.filename,
        linter_name: "remark",
        patch: commit_file.patch,
        pull_request_number: build.pull_request_number,
      )
    end
  end

  def stub_remark_config(content: "")
    stubbed_remark_config = double(
      "RemarkConfig",
      content: content,
      serialize: content.to_s,
      merge: content.to_s,
    )
    allow(Config::Remark).to receive(:new).and_return(stubbed_remark_config)

    stubbed_remark_config
  end

  def raw_hound_config
    <<-EOS.strip_heredoc
      remark:
        enabled: true
        config_file: config/.remarkrc
    EOS
  end
end
