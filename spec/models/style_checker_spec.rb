require "rails_helper"

describe StyleChecker do
  describe "#review_files" do
    it "returns a collection of file reviews with violations" do
      stylish_commit_file = stub_commit_file("good.rb", "def good; end")
      violated_commit_file = stub_commit_file("bad.rb", "def bad(a ); a; end  ")
      pull_request = stub_pull_request(
        commit_files: [stylish_commit_file, violated_commit_file],
      )

      violation_messages = pull_request_violations(pull_request)

      expect(violation_messages).to include "Trailing whitespace detected."
    end

    it "only fetches content for supported files" do
      ruby_file = double("GithubFile", filename: "ruby.rb", patch: "foo")
      bogus_file = double("GithubFile", filename: "[:facebook]", patch: "bar")
      head_commit = double("Commit", file_content: "foo bar")
      pull_request = PullRequest.new(payload_stub, "anything")
      allow(pull_request).to receive(:head_commit).and_return(head_commit)
      allow(pull_request).to receive(:modified_github_files).
        and_return([bogus_file, ruby_file])

      pull_request_violations(pull_request)

      expect(head_commit).to have_received(:file_content).
        with(ruby_file.filename)
      expect(head_commit).not_to have_received(:file_content).
        with(bogus_file.filename)
    end

    context "for a Ruby file" do
      context "with style violations" do
        it "returns violations" do
          commit_file = stub_commit_file("ruby.rb", "puts 123    ")
          pull_request = stub_pull_request(commit_files: [commit_file])

          violation_messages = pull_request_violations(pull_request)

          expect(violation_messages).to include "Trailing whitespace detected."
        end
      end

      context "with style violation on unchanged line" do
        it "returns no violations" do
          commit_file = stub_commit_file(
            "foo.rb",
            "'wrong quotes'",
            UnchangedLine.new,
          )
          pull_request = stub_pull_request(commit_files: [commit_file])

          violation_messages = pull_request_violations(pull_request)

          expect(violation_messages).to be_empty
        end
      end

      context "without style violations" do
        it "returns no violations" do
          commit_file = stub_commit_file("ruby.rb", "puts 123")
          pull_request = stub_pull_request(commit_files: [commit_file])

          violation_messages = pull_request_violations(pull_request)

          expect(violation_messages).to be_empty
        end
      end
    end

    context "for a CoffeeScript file" do
      context "with .coffee extension" do
        it "finds violations" do
          commit_file = stub_commit_file("test.coffee", "debugger")
          pull_request = stub_pull_request(commit_files: [commit_file])

          violation_messages = pull_request_violations(pull_request)

          expect(violation_messages).to include(
            "Found debugging code",
          )
        end
      end

      context "with .coffee.js extension" do
        it "finds violations" do
          commit_file = stub_commit_file("test.coffee.js", "debugger")
          pull_request = stub_pull_request(commit_files: [commit_file])
          allow(RepoConfig).to receive(:new).and_return(stub_repo_config)

          violation_messages = pull_request_violations(pull_request)

          expect(violation_messages).to include(
            "Found debugging code",
          )
        end
      end

      context "with .coffee.erb extension" do
        it "finds violations" do
          commit_file = stub_commit_file(
            "test.coffee.erb",
            "class strange_ClassNAME",
          )
          pull_request = stub_pull_request(commit_files: [commit_file])
          allow(RepoConfig).to receive(:new).and_return(stub_repo_config)

          violation_messages = pull_request_violations(pull_request)

          expect(violation_messages).to include(
            "Class name should be UpperCamelCased",
          )
        end
      end

      context "without style violations" do
        it "returns no violations" do
          commit_file = stub_commit_file("test.coffee", "alert('Hello World')")
          pull_request = stub_pull_request(commit_files: [commit_file])

          violation_messages = pull_request_violations(pull_request)

          expect(violation_messages).to be_empty
        end
      end
    end

    context "for a JavaScript file" do
      context "with style violations" do
        it "returns violations" do
          commit_file = stub_commit_file("test.js", "var test = 'test'")
          pull_request = stub_pull_request(commit_files: [commit_file])

          violation_messages = pull_request_violations(pull_request)

          expect(violation_messages).to include "Missing semicolon."
        end
      end

      context "without style violations" do
        it "returns no violations" do
          commit_file = stub_commit_file("test.js", "var test = 'test';")
          pull_request = stub_pull_request(commit_files: [commit_file])

          violation_messages = pull_request_violations(pull_request)

          expect(violation_messages).not_to include "Missing semicolon."
        end
      end

      context "an excluded file" do
        it "returns no violations" do
          config = <<-YAML.strip_heredoc
            javascript:
              ignore_file: '.jshintignore'
          YAML

          head_commit = stub_head_commit(
            ".hound.yml" => config,
            ".jshintignore" => "test.js",
          )

          commit_file = stub_commit_file("test.js", "var test = 'test'")
          pull_request = stub_pull_request(
            head_commit: head_commit,
            commit_files: [commit_file],
          )

          violation_messages = pull_request_violations(pull_request)

          expect(violation_messages).to be_empty
        end
      end
    end

    context "for a SCSS file" do
      it "does not immediately return violations" do
        commit_file = stub_commit_file("test.scss", "* { color: red; }")
        pull_request = stub_pull_request(commit_files: [commit_file])

        violation_messages = pull_request_violations(pull_request)

        expect(violation_messages).to be_empty
      end
    end

    context "for a Python file" do
      it "does not immediately return violations" do
        commit_file = stub_commit_file("test.py", "import this")
        pull_request = stub_pull_request(commit_files: [commit_file])

        violation_messages = pull_request_violations(pull_request)

        expect(violation_messages).to be_empty
      end
    end

    context "for a Haml file" do
      context "with style violations" do
        it "returns violations" do
          commit_file = stub_commit_file("test.haml", "%div.message 123")
          pull_request = stub_pull_request(commit_files: [commit_file])
          message = "`%div.message` can be written as `.message` since `%div` "\
            "is implicit"

          violation_messages = pull_request_violations(pull_request)

          expect(violation_messages).to include message
        end
      end

      context "without style violations" do
        it "returns no violations" do
          commit_file = stub_commit_file("test.haml", ".foo 123")
          pull_request = stub_pull_request(commit_files: [commit_file])

          violation_messages = pull_request_violations(pull_request)

          expect(violation_messages).not_to include(
            "`%div.foo` can be written as `.foo` since `%div` is implicit",
          )
        end
      end
    end

    context "with unsupported file type" do
      it "uses the unsupported linter" do
        commit_file = stub_commit_file(
          "fortran.f",
          %{PRINT *, "Hello World!"\nEND},
        )
        pull_request = stub_pull_request(commit_files: [commit_file])

        violation_messages = pull_request_violations(pull_request)

        expect(violation_messages).to be_empty
      end
    end
  end

  def pull_request_violations(pull_request)
    build = build(:build)
    StyleChecker.new(pull_request, build).review_files

    build.violations.flat_map(&:messages)
  end

  def stub_pull_request(options = {})
    head_commit = double("Commit", file_content: "")
    defaults = {
      file_content: "",
      head_commit: head_commit,
      commit_files: [],
      repository_owner_name: "some_org"
    }

    double("PullRequest", defaults.merge(options))
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

  def stub_head_commit(options)
    head_commit = double("Commit", file_content: nil)

    options.each do |filename, file_contents|
      allow(head_commit).to receive(:file_content).
        with(filename).and_return(file_contents)
    end

    head_commit
  end

  def stub_repo_config
    double(
      "RepoConfig",
      enabled_for?: true,
      for: {},
      ignored_javascript_files: []
    )
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
