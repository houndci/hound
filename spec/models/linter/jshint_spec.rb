require "rails_helper"

describe Linter::Jshint do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.js) }
    let(:not_lintable_files) { %w(foo.js.coffee foo.rb) }
  end

  describe "#file_included?" do
    context "when file does not match any ignore patterns" do
      it "returns true" do
        linter = build_linter(nil, Linter::Jshint::IGNORE_FILENAME => "foo.js")
        commit_file = double("CommitFile", filename: "bar.js")

        expect(linter.file_included?(commit_file)).to eq true
      end
    end

    context "when file matches an ignore pattern" do
      it "returns false" do
        linter = build_linter(
          nil,
          Linter::Jshint::IGNORE_FILENAME => "app/javascripts/*.js\nvendor/*",
        )
        commit_file1 = double(
          "CommitFile",
          filename: "app/javascripts/bar.js",
        )
        commit_file2 = double(
          "CommitFile",
          filename: "vendor/javascripts/foo.js",
        )

        expect(linter.file_included?(commit_file1)).to be false
        expect(linter.file_included?(commit_file2)).to be false
      end
    end
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      commit_file = build_commit_file(filename: "lib/a.js")
      linter = build_linter

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    context "when the owner has no config enabled" do
      it "schedules a review job with the local config" do
        config = <<~EOS
          {
            // Define globals exposed by modern browsers.
            "browser": true
          }
        EOS
        build = create(:build)
        linter = build_linter(build, stub_config_files(config))
        commit_file = build_commit_file(filename: "lib/a.js")
        allow(LintersJob).to receive(:perform_async)

        linter.file_review(commit_file)

        expect(LintersJob).to have_received(:perform_async).with(
          commit_sha: build.commit_sha,
          config: '{"browser":true}',
          content: commit_file.content,
          filename: commit_file.filename,
          linter_name: "jshint",
          patch: commit_file.patch,
          pull_request_number: build.pull_request_number,
          linter_version: nil,
        )
      end
    end

    context "when there is an owner level config enabled" do
      it "schedules a review job with the owner's config merged with locals" do
        build = create_build
        linter = build_linter(build, stub_config_files('{"asi": true}'))
        commit_file = build_commit_file(filename: "lib/a.js")
        stub_owner_config('{"asi": false, "maxlen": 50}')
        allow(LintersJob).to receive(:perform_async)

        linter.file_review(commit_file)

        expect(LintersJob).to have_received(:perform_async).with(
          commit_sha: build.commit_sha,
          config: '{"asi":true,"maxlen":50}',
          content: commit_file.content,
          filename: commit_file.filename,
          linter_name: "jshint",
          patch: commit_file.patch,
          pull_request_number: build.pull_request_number,
          linter_version: nil,
        )
      end
    end
  end

  def create_build
    owner = create(:owner)
    repo = create(:repo, owner: owner)
    create(:build, repo: repo, commit_sha: "foo", pull_request_number: 5)
  end

  def stub_config_files(config_content)
    stubbed_hound_yml = <<~YML
      "jshint":
        "config_file": ".jshintrc"
    YML

    {
      ".jshintrc" => config_content,
      ".hound.yml" => stubbed_hound_yml,
    }
  end

  def stub_owner_config(content)
    commit = stub_commit(".jshintrc" => content)
    hound_config = build_hound_config(commit, ".jshintrc")
    allow(BuildOwnerHoundConfig).to receive(:call).and_return(hound_config)
  end
end
