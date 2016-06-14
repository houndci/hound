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
    it "returns a saved and incomplete file review" do
      linter = build_linter
      commit_file = build_commit_file(filename: "lib/a.scss")
      stub_owner_hound_config

      result = linter.file_review(commit_file)

      expect(result).to be_persisted
      expect(result).not_to be_completed
    end

    it "schedules a review job" do
      build = build(:build, commit_sha: "foo", pull_request_number: 123)
      linter = build_linter(build)
      stub_scss_config({})
      stub_owner_hound_config
      commit_file = build_commit_file(filename: "lib/a.scss")
      allow(Resque).to receive(:enqueue)

      linter.file_review(commit_file)

      expect(Resque).to have_received(:enqueue).with(
        ScssReviewJob,
        filename: commit_file.filename,
        commit_sha: build.commit_sha,
        linter_name: "scss",
        pull_request_number: build.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: "{}",
      )
    end

    context "when the owner has a config repo set" do
      it "schedules a review job with the owner's config" do
        owner = build(
          :owner,
          config_enabled: true,
          config_repo: "organization/style",
        )
        stub_file_on_repo(
          repo: "organization/style",
          file: ".hound.yml",
          contents: <<~EOF,
            scss:
              config_file: .scss.yml
            EOF
          user_token: Hound::GITHUB_TOKEN,
        )
        stub_file_on_repo(
          repo: "organization/style",
          file: ".scss.yml",
          contents: "some key: some value",
          user_token: Hound::GITHUB_TOKEN,
        )
        repo = build(:repo, owner: owner)
        build = build(
          :build,
          commit_sha: "foo",
          pull_request_number: 123,
          repo: repo,
        )
        linter = build_linter(build)
        commit_file = build_commit_file(filename: "lib/a.scss")
        allow(Resque).to receive(:enqueue)

        linter.file_review(commit_file)

        expect(Resque).to have_received(:enqueue).with(
          ScssReviewJob,
          commit_sha: build.commit_sha,
          config: "---\nsome key: some value\n",
          content: commit_file.content,
          filename: commit_file.filename,
          linter_name: "scss",
          patch: commit_file.patch,
          pull_request_number: build.pull_request_number,
        )
      end
    end
  end

  def stub_scss_config(config = {})
    stubbed_scss_config = double(
      "ScssConfig",
      content: config,
      merge: config.to_s,
    )
    allow(Config::Scss).to receive(:new).and_return(stubbed_scss_config)

    stubbed_scss_config
  end

  def stub_file_on_repo(repo:, file:, contents:, user_token:)
    stub_request(
      :get,
      "https://api.github.com/repos/#{repo}/contents/#{file}?ref=HEAD",
    ).with(headers: { "Authorization" => "token #{user_token}" }).
      to_return(
        status: 200,
        body: stub_contents(contents),
        headers: {},
      )
  end

  def stub_contents(contents)
    instance_double("Contents", content: Base64.encode64(contents))
  end
end
