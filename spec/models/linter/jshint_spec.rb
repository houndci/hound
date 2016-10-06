require "rails_helper"

describe Linter::Jshint do
  describe ".can_lint?" do
    context "given a .js file" do
      it "returns true" do
        result = Linter::Jshint.can_lint?("foo.js")

        expect(result).to eq true
      end
    end

    context "given a .js.coffee file" do
      it "returns false" do
        result = Linter::Jshint.can_lint?("foo.js.coffee")

        expect(result).to eq false
      end
    end

    context "given a non-js file" do
      it "returns false" do
        result = Linter::Jshint.can_lint?("foo.rb")

        expect(result).to eq false
      end
    end
  end

  describe "#file_included?" do
    context "file is in excluded file list" do
      it "returns false" do
        linter = build_linter(nil, Linter::Jshint::IGNORE_FILENAME => "foo.js")
        commit_file = double("CommitFile", filename: "foo.js")

        expect(linter.file_included?(commit_file)).to eq false
      end
    end

    context "file is not excluded" do
      it "returns true" do
        linter = build_linter(nil, Linter::Jshint::IGNORE_FILENAME => "foo.js")
        commit_file = double("CommitFile", filename: "bar.js")

        expect(linter.file_included?(commit_file)).to eq true
      end

      it "matches a glob pattern" do
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
      stub_owner_hound_config(instance_double("HoundConfig", content: {}))
      commit_file = build_commit_file(filename: "lib/a.js")
      linter = build_linter

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    context "when the owner has no config enabled" do
      it "schedules a review job with the local config" do
        stub_owner_hound_config(instance_double("HoundConfig", content: {}))
        build = create(:build, commit_sha: "foo", pull_request_number: 123)
        commit_file = build_commit_file(filename: "lib/a.js")
        stubbed_local_config = stub_config_files('{"asi": true}')
        linter = build_linter(build, stubbed_local_config)
        allow(Resque).to receive(:enqueue)

        linter.file_review(commit_file)

        expect(Resque).to have_received(:enqueue).with(
          JshintReviewJob,
          commit_sha: build.commit_sha,
          config: '{"asi":true}',
          content: commit_file.content,
          filename: commit_file.filename,
          linter_name: "jshint",
          patch: commit_file.patch,
          pull_request_number: build.pull_request_number,
        )
      end
    end

    context "when there is an owner level config enabled" do
      it "schedules a review job with the owner's config merged with locals" do
        build = create(:build, commit_sha: "foo", pull_request_number: 123)
        stubbed_local_config = stub_config_files('{"asi": false, "maxlen": 50}')
        stub_owner_hound_config(
          HoundConfig.new(
            stubbed_commit(stubbed_local_config),
          ),
        )
        linter = build_linter(build, stub_config_files('{"asi": true}'))
        commit_file = build_commit_file(filename: "lib/a.js")

        allow(Resque).to receive(:enqueue)

        linter.file_review(commit_file)

        expect(Resque).to have_received(:enqueue).with(
          JshintReviewJob,
          commit_sha: build.commit_sha,
          config: '{"asi":true,"maxlen":50}',
          content: commit_file.content,
          filename: commit_file.filename,
          linter_name: "jshint",
          patch: commit_file.patch,
          pull_request_number: build.pull_request_number,
        )
      end
    end
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

  def stub_owner_hound_config(config)
    allow(BuildOwnerHoundConfig).to receive(:run).and_return(config)
  end
end
