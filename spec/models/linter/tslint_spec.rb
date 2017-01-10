require "rails_helper"

describe Linter::Tslint do
  describe ".can_lint?" do
    context "given a .ts file" do
      it "returns true" do
        result = Linter::Tslint.can_lint?("foo.ts")

        expect(result).to eq true
      end
    end

    context "given a non-typescript file" do
      it "returns false" do
        result = Linter::Tslint.can_lint?("foo.js.coffee")

        expect(result).to eq false
      end
    end
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      commit_file = build_commit_file(filename: "lib/a.ts")
      linter = build_linter
      owner_config = instance_double("Config::Tslint", serialize: {})
      allow(BuildConfig).to receive(:for).and_return(owner_config)

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      stub_tslint_config(content: {})
      commit_file = build_commit_file(filename: "lib/a.ts")
      allow(Resque).to receive(:enqueue)
      linter = build_linter(build)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        TslintReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "tslint",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
      )
    end
  end

  def stub_tslint_config(content: {}, excluded_paths: [])
    stubbed_tslint_config = double(
      "TslintConfig",
      content: content,
      excluded_paths: excluded_paths,
      serialize: content.to_s,
    )
    allow(Config::Tslint).to receive(:new).and_return(stubbed_tslint_config)

    stubbed_tslint_config
  end

  def raw_hound_config
    <<~EOS
      tslint:
        enabled: true
        config_file: config/tslint.json
    EOS
  end
end
