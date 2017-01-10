require "rails_helper"

describe Linter::CoffeeScript do
  describe ".can_lint?" do
    context "given a .coffee file" do
      it "returns true" do
        result = Linter::CoffeeScript.can_lint?("foo.coffee")

        expect(result).to eq true
      end
    end

    context "given a .coffee.erb file" do
      it "returns true" do
        result = Linter::CoffeeScript.can_lint?("foo.coffee.erb")

        expect(result).to eq true
      end
    end

    context "given a .coffee.js file" do
      it "returns true" do
        result = Linter::CoffeeScript.can_lint?("foo.coffee.js")

        expect(result).to eq true
      end
    end

    context "given a non-coffee file" do
      it "returns false" do
        result = Linter::CoffeeScript.can_lint?("foo.js")

        expect(result).to eq false
      end
    end
  end

  describe "#file_review" do
    it "returns a saved and incomplete file review" do
      linter = build_linter
      commit_file = build_commit_file(filename: "foo.coffee.js")
      owner_config = instance_double("Config::CoffeeScript", serialize: {})
      allow(BuildConfig).to receive(:for).and_return(owner_config)

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      linter = build_linter(build)
      stub_coffeelint_config({})
      commit_file = build_commit_file(filename: "foo.coffee.js")
      allow(Resque).to receive(:enqueue)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        CoffeelintReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "coffee_script",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
      )
    end
  end

  def stub_coffeelint_config(config = {})
    stubbged_config = instance_double(
      Config::CoffeeScript,
      content: config,
      serialize: Config::Serializer.json(config),
    )
    allow(Config::CoffeeScript).to receive(:new).and_return(stubbged_config)

    stubbged_config
  end
end
