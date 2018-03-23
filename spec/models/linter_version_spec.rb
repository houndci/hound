require "lib/github_api"
require "app/models/linter_version"

RSpec.describe LinterVersion do
  describe ".all" do
    it "returns a hash of linter versions" do
      linter_version = described_class.new
      gemfile_content = <<~TEXT
        GEM
          spec:
            haml_lint (0.25.1)
              rubocop (>= 0.47.0)
            ice_nine (0.11.2)
            rubocop (0.51.0)
      TEXT
      yarn_content = <<~TEXT
        eslint-plugin-standard@^3.0.1:
          version "3.0.1"
          dependencies:
            commander "^2.8.1"
            eslint "^2.7.0"

        eslint@^2.7.0:
          version "2.13.1"
          dependencies:
            chalk "^1.1.3"

        eslint@^3.7.1:
          version "3.7.1"

        eslint@^3.19.1:
          version "3.19.0"
      TEXT
      stub_file_requests(
        "Gemfile.lock" => gemfile_content,
        "yarn.lock" => yarn_content,
      )

      result = linter_version.all

      expect(result).to include(
        eslint: "3.19.0",
        haml_lint: "0.25.1",
        rubocop: "0.51.0",
      )
    end
  end

  def stub_file_requests(files)
    github_client = instance_double("GitHubApi", file_contents: nil)
    allow(GitHubApi).to receive(:new).and_return(github_client)

    files.each do |filename, contents|
      file_contents = Base64.encode64(contents)
      file_response = OpenStruct.new(content: file_contents)
      allow(github_client).to receive(:file_contents).with(
        described_class::LINTERS_REPO_NAME,
        filename,
        "master",
      ).and_return(file_response)
    end
  end
end
