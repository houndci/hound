require "rails_helper"

describe Linter::HamlLint do
  let(:filename) { "app/views/show.html.haml" }

  describe ".can_lint?" do
    context "given a .haml file" do
      it "returns true" do
        result = Linter::HamlLint.can_lint?("foo.haml")

        expect(result).to eq true
      end
    end

    context "given a non-haml file" do
      it "returns false" do
        result = Linter::HamlLint.can_lint?("foo.rb")

        expect(result).to eq false
      end
    end
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      linter = build_linter
      commit_file = build_commit_file(filename: "lib/a.haml")

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      linter = build_linter(build)
      stub_haml_config({})
      commit_file = build_commit_file(filename: "lib/a.haml")
      allow(Resque).to receive(:enqueue)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        HamlLintReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: described_class.name.demodulize.underscore,
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
      )
    end
  end

  private

  def stub_haml_config(config = {})
    stubbed_haml_config = double(
      "HamlLintConfig",
      content: config,
      serialize: config.to_s,
    )
    allow(Config::HamlLint).to receive(:new).and_return(stubbed_haml_config)

    stubbed_haml_config
  end
end
