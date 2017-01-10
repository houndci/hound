require "rails_helper"

describe Linter::Ruby do
  describe ".can_lint?" do
    context "given a .rb file" do
      it "returns true" do
        result = Linter::Ruby.can_lint?("foo.rb")

        expect(result).to eq true
      end
    end

    context "given a .rake file" do
      it "returns true" do
        result = Linter::Ruby.can_lint?("foo.rake")

        expect(result).to eq true
      end
    end

    context "given a non-ruby file" do
      it "returns false" do
        result = Linter::Ruby.can_lint?("foo.js")

        expect(result).to eq false
      end
    end
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      linter = build_linter
      commit_file = build_commit_file(filename: "lib/a.rb")
      owner_config = instance_double("Config::Ruby", serialize: {})
      allow(BuildConfig).to receive(:for).and_return(owner_config)

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      linter = build_linter(build)
      stub_ruby_config({})
      commit_file = build_commit_file(filename: "lib/a.rb")
      allow(Resque).to receive(:enqueue)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        RubocopReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "ruby",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "--- {}\n",
      )
    end
  end

  private

  def stub_ruby_config(config = {})
    stubbed_ruby_config = instance_double(
      Config::Ruby,
      content: config,
      serialize: Config::Serializer.yaml(config),
    )
    allow(Config::Ruby).to receive(:new).and_return(stubbed_ruby_config)

    stubbed_ruby_config
  end
end
