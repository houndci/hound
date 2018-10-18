require "rails_helper"

describe Linter::Flake8 do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.py) }
    let(:not_lintable_files) { %w(foo.rb) }
  end

  describe "#file_review" do
    it "returns a saved, incomplete file review" do
      linter = build_linter
      commit_file = build_commit_file
      stub_flake8_config

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      allow(Resque).to receive(:push)
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      linter = build_linter(build)
      stub_flake8_config("config")
      commit_file = build_commit_file

      linter.file_review(commit_file)

      expect(Resque).to have_received(:push).with(
        "linters",
        {
          class: "LintersJob",
          args: [
            filename: commit_file.filename,
            commit_sha: build.commit_sha,
            linter_name: "flake8",
            pull_request_number: build.pull_request_number,
            patch: commit_file.patch,
            content: commit_file.content,
            config: "config",
            linter_version: nil,
          ],
        }
      )
    end
  end

  def build_commit_file
    line = double(
      "Line",
      changed?: true,
      content: "blah",
      number: 1,
      patch_position: 2,
    )
    double(
      "CommitFile",
      content: "codes",
      filename: "lib/a.py",
      line_at: line,
      patch: "patch",
    )
  end

  def stub_flake8_config(config = "config")
    stubbed_flake8_config = double(
      "Flake8Config",
      content: config,
      serialize: config,
    )
    allow(Config::Flake8).to receive(:new).and_return(stubbed_flake8_config)

    stubbed_flake8_config
  end
end
