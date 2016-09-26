require "rails_helper"

describe Linter::Scss do
  describe ".can_lint?" do
    context "given an .scss file" do
      it "returns true" do
        result = Linter::Scss.can_lint?("foo.scss")

        expect(result).to eq true
      end
    end

    context "given a non-scss file" do
      it "returns false" do
        result = Linter::Scss.can_lint?("foo.css")

        expect(result).to eq false
      end
    end
  end

  describe "#file_review" do
    context "when the owner does not have a configuration set up" do
      it "enqueues a file review with the local config" do
        build = build(:build, commit_sha: "foo", pull_request_number: 123)
        config_content = <<~EOS
          linters:
            Indentation:
              width: 2
        EOS
        linter = build_linter(build, "config/scss.yml" => config_content)
        commit_file = build_commit_file(filename: "lib/a.scss")
        stub_owner_hound_config(instance_double("HoundConfig", content: {}))
        allow(Resque).to receive(:enqueue)

        linter.file_review(commit_file)

        expect(Resque).to have_received(:enqueue).with(
          ScssReviewJob,
          commit_sha: build.commit_sha,
          config: "---\n#{config_content}",
          content: commit_file.content,
          filename: commit_file.filename,
          linter_name: "scss",
          patch: commit_file.patch,
          pull_request_number: build.pull_request_number,
        )
      end
    end

    context "when the owner has a configuration set up" do
      it "enqueues a file review with the owner config merged with the local" do
        hound_yml= <<~EOS
          scss:
            config_file: .scss.yml
        EOS
        scss_yml = <<~EOS
          linters:
            BorderZero:
              enabled: false
            Indentation:
              width: 1
        EOS

        stubbed_owner_config = stubbed_commit(
          ".hound.yml" => hound_yml,
          ".scss.yml" => scss_yml,
        )
        stub_owner_hound_config(HoundConfig.new(stubbed_owner_config))
        build = build(:build, commit_sha: "foo", pull_request_number: 123)
        config_content = <<~EOS
          linters:
            Indentation:
              width: 2
        EOS
        linter = build_linter(build, "config/scss.yml" => config_content)
        commit_file = build_commit_file(filename: "lib/a.scss")
        allow(Resque).to receive(:enqueue)

        linter.file_review(commit_file)

        expect(Resque).to have_received(:enqueue).with(
          ScssReviewJob,
          commit_sha: build.commit_sha,
          config: <<~EOS,
            ---
            linters:
              BorderZero:
                enabled: false
              Indentation:
                width: 2
          EOS
          content: commit_file.content,
          filename: commit_file.filename,
          linter_name: "scss",
          patch: commit_file.patch,
          pull_request_number: build.pull_request_number,
        )
      end
    end

    it "returns a saved and incomplete file review" do
      linter = build_linter
      commit_file = build_commit_file(filename: "lib/a.scss")
      stub_owner_hound_config(instance_double("HoundConfig", content: {}))

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end
  end

  def stub_scss_config(config = {})
    stubbed_scss_config = double(
      "ScssConfig",
      content: config,
      serialize: config.to_s,
    )
    allow(Config::Scss).to receive(:new).and_return(stubbed_scss_config)

    stubbed_scss_config
  end

  def stub_owner_hound_config(config)
    allow(BuildOwnerHoundConfig).to receive(:run).and_return(config)
  end
end
