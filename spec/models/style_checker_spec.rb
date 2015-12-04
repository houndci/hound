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
      head_commit = stub_head_commit(ruby_file.filename => "")
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
      it "is processed with a coffee.js extension" do
        commit_file = stub_commit_file("test.js.coffee", "foo ->")
        pull_request = stub_pull_request(commit_files: [commit_file])

        violation_messages = pull_request_violations(pull_request)

        expect(violation_messages).to eq ["Empty function"]
      end

      it "is processed with a coffee.erb extension" do
        commit_file = stub_commit_file(
          "test.coffee.erb",
          "class strange_ClassNAME",
        )
        pull_request = stub_pull_request(commit_files: [commit_file])

        violation_messages = pull_request_violations(pull_request)

        expect(violation_messages).to eq [
          "Class name should be UpperCamelCased",
        ]
      end

      context "with style violations" do
        it "returns violations" do
          commit_file = stub_commit_file("test.coffee", "foo: ->")
          pull_request = stub_pull_request(commit_files: [commit_file])

          violation_messages = pull_request_violations(pull_request)

          expect(violation_messages).to eq ["Empty function"]
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
      context "when Eslint is enabled" do
        it "creates violations" do
          commit_file = stub_commit_file("test.js", "var test = 'test'")
          head_commit = stub_head_commit(
            HoundConfig::CONFIG_FILE => <<-EOS.strip_heredoc
              eslint:
                enabled: true
                config_file: config/.eslintrc
            EOS
          )
          pull_request = stub_pull_request(
            commit_files: [commit_file],
            head_commit: head_commit,
          )

          violation_messages = pull_request_violations(pull_request)

          expect(violation_messages).to eq [
            "Missing semicolon.",
            "'test' is defined but never used.",
          ]
        end
      end

      context "when JSCS is enabled" do
        it "creates violations" do
          commit_file = stub_commit_file("test.js", "var test = 'test'")
          head_commit = stub_head_commit(
            HoundConfig::CONFIG_FILE => <<-EOS.strip_heredoc
              jscs:
                enabled: true
                config_file: config/.jscsrc
            EOS
          )
          pull_request = stub_pull_request(
            commit_files: [commit_file],
            head_commit: head_commit,
          )

          violation_messages = pull_request_violations(pull_request)

          expect(violation_messages).to eq [
            "Missing semicolon.",
            "'test' is defined but never used.",
          ]
        end
      end

      context "when JSHint is enabled" do
        it "creates violations" do
          commit_file = stub_commit_file("test.js", "var test = 'test'")
          head_commit = stub_head_commit(
            HoundConfig::CONFIG_FILE => <<-EOS.strip_heredoc
              jshint:
                enabled: true
                config_file: config/.jshintrc
              javascript:
                enabled: false
            EOS
          )
          pull_request = stub_pull_request(
            commit_files: [commit_file],
            head_commit: head_commit,
          )

          violation_messages = pull_request_violations(pull_request)

          expect(violation_messages).to eq []
        end
      end

      context "when a specifc linter is disabled or unconfigured" do
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
    end

    context "for a SCSS file" do
      it "creates violations" do
        commit_file = stub_commit_file("test.scss", "* { color: red; }")
        pull_request = stub_pull_request(commit_files: [commit_file])

        violation_messages = pull_request_violations(pull_request)

        expect(violation_messages).to be_empty
      end
    end

    context "for a Python file" do
      it "creates violations" do
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

    context "for a Markdown file" do
      it "creates violations" do
        commit_file = stub_commit_file("test.md", "# Hello!")
        pull_request = stub_pull_request(commit_files: [commit_file])

        violation_messages = pull_request_violations(pull_request)

        expect(violation_messages).to be_empty
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
    defaults = {
      file_content: "",
      head_commit: stubbed_head_commit,
      commit_files: [],
      repository_owner_name: "some_org"
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
    head_commit = double("Commit", file_content: nil)

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
