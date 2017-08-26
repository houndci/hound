require "rails_helper"

describe StyleChecker do
  describe "#review_files" do
    it "returns a collection of incomplete file reviews" do
      stylish_commit_file = stub_commit_file("good.rb", "def good; end")
      violated_commit_file = stub_commit_file("bad.rb", "def bad(a ); a; end  ")
      pull_request = stub_pull_request(
        commit_files: [stylish_commit_file, violated_commit_file],
      )

      file_reviews = pull_request_file_reviews(pull_request)

      expect(file_reviews.map(&:filename)).to match_array ["good.rb", "bad.rb"]
    end

    it "only fetches content for supported files" do
      ruby_file = double("GithubFile", filename: "ruby.rb", patch: "foo")
      bogus_file = double("GithubFile", filename: "[:facebook]", patch: "bar")
      config = <<~YAML
        ruby:
          enabled: true
      YAML
      head_commit = stub_head_commit(".hound.yml" => config,)
      pull_request = PullRequest.new(payload_stub, "anything")
      allow(pull_request).to receive(:head_commit).and_return(head_commit)
      allow(pull_request).to receive(:modified_github_files).
        and_return([bogus_file, ruby_file])

      pull_request_violation_messages(pull_request)

      expect(head_commit).to have_received(:file_content).
        with(ruby_file.filename)
      expect(head_commit).not_to have_received(:file_content).
        with(bogus_file.filename)
    end

    context "with unsupported file type" do
      it "uses the unsupported linter" do
        commit_file = stub_commit_file(
          "fortran.f",
          %{PRINT *, "Hello World!"\nEND},
        )
        pull_request = stub_pull_request(commit_files: [commit_file])

        violation_messages = pull_request_violation_messages(pull_request)

        expect(violation_messages).to be_empty
      end
    end
  end

  def pull_request_file_reviews(pull_request)
    repo = build(:repo, owner: build(:owner, config_enabled: false))
    build = build(:build, repo: repo)

    StyleChecker.new(pull_request, build).review_files

    build.file_reviews
  end

  def pull_request_violation_messages(pull_request)
    build = build(
      :build,
      repo: build(:repo, owner: build(:owner, config_enabled: false)),
    )
    StyleChecker.new(pull_request, build).review_files

    build.violations.flat_map(&:messages)
  end

  def stub_pull_request(options = {})
    defaults = {
      file_content: "",
      head_commit: stubbed_head_commit,
      commit_files: [],
    }

    double("PullRequest", defaults.merge(options))
  end

  def stubbed_head_commit
    head_commit = double("Commit", file_content: "{}")
    allow(head_commit).to receive(:file_content).with(".hound.yml").
      and_return(raw_hound_config)

    head_commit
  end

  def stub_commit_file(filename, contents, line = nil)
    line ||= Line.new(content: "foo", number: 1, patch_position: 2)
    formatted_contents = "#{contents}\n"
    double(
      "CommitFile",
      filename: filename,
      content: formatted_contents,
      line_at: line,
      sha: "abc123",
      patch: "patch",
      pull_request_number: 123
    )
  end

  def stub_head_commit(options = {})
    default_options = {
      HoundConfig::CONFIG_FILE => raw_hound_config,
    }
    head_commit = double("Commit", file_content: "")

    default_options.merge(options).each do |filename, file_contents|
      allow(head_commit).to receive(:file_content).
        with(filename).and_return(file_contents)
    end

    head_commit
  end

  def payload_stub
    double(
      "Payload",
      full_repo_name: "foo/bar",
      head_sha: "abc",
      repository_owner_name: "ralph",
    )
  end
end
