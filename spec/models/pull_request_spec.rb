require "spec_helper"

describe PullRequest do
  describe "#head_includes?" do
    context "when HEAD commit includes line" do
      it "returns true" do
        patch_line = "+ A line of code"
        pull_request = build_pull_request(patch_line)

        includes_line = pull_request.head_includes?(Line.new(patch_line))

        expect(includes_line).to be_true
      end
    end

    context "when HEAD commit does not include line" do
      it "returns false" do
        patch_line1 = "+ A line of code"
        patch_line2 = "+ Different line of code"
        pull_request = build_pull_request(patch_line1)

        includes_line = pull_request.head_includes?(Line.new(patch_line2))

        expect(includes_line).to be_false
      end
    end

    def build_pull_request(patch_line)
      file_response = double(
        :file_response,
        filename: "test.rb",
        status: "added",
        patch: "@@ -1,1 +1,1\n#{patch_line}",
        content: ""
      )
      content = double(content: "")
      github_api = double(commit_files: [file_response], file_contents: content)
      pull_request(github_api)
    end
  end

  describe "#opened?" do
    context "when payload action is opened" do
      it "returns true" do
        payload = double(:payload, action: "opened")
        pull_request = PullRequest.new(payload, "token")

        expect(pull_request).to be_opened
      end
    end

    context "when payload action is not opened" do
      it "returns false" do
        payload = double(:payload, action: "notopened")
        pull_request = PullRequest.new(payload, "token")

        expect(pull_request).not_to be_opened
      end
    end
  end

  describe "#synchronize?" do
    context "when payload action is synchronize" do
      it "returns true" do
        payload = double(:payload, action: "synchronize")
        pull_request = PullRequest.new(payload, "token")

        expect(pull_request).to be_synchronize
      end
    end

    context "when payload action is not synchronize" do
      it "returns false" do
        payload = double(:payload, action: "notsynchronize")
        pull_request = PullRequest.new(payload, "token")

        expect(pull_request).not_to be_synchronize
      end
    end
  end

  describe "#comments" do
    it "returns comments on pull request" do
      payload = double(
        :payload,
        full_repo_name: "org/repo",
        number: 4,
        head_sha: "abc123"
      )
      patch_position = 7
      filename = "spec/models/style_guide_spec.rb"
      comment = double(:comment, position: patch_position, path: filename)
      github_api = double(:github_api, pull_request_comments: [comment])
      GithubApi.stub(new: github_api)
      pull_request = PullRequest.new(payload, "githubtoken")

      comments = pull_request.comments

      expect(comments).to have(1).item
      expect(comments).to match_array([comment])
    end
  end

  describe "#add_comment" do
    it "posts a comment to GitHub for the Hound user" do
      payload = double(
        :payload,
        full_repo_name: "org/repo",
        number: "123",
        head_sha: "1234abcd"
      )
      commit = double(:commit, repo_name: payload.full_repo_name)
      client = double(:github_client, add_comment: nil)
      GithubApi.stub(new: client)
      Commit.stub(new: commit)
      pull_request = PullRequest.new(payload, "gh-token")

      pull_request.add_comment("test.rb", 123, "A comment")

      expect(GithubApi).to have_received(:new).with(ENV["HOUND_GITHUB_TOKEN"])
      expect(client).to have_received(:add_comment).with(
        pull_request_number: payload.number,
        commit: commit,
        comment: "A comment",
        filename: "test.rb",
        patch_position: 123
      )
    end
  end

  describe "#config" do
    context "when config file is present" do
      it "returns the contents of custom config" do
        file_contents = double(:file_contents, content: Base64.encode64("test"))
        api = double(:github_api, file_contents: file_contents)
        pull_request = pull_request(api)

        config = pull_request.config

        expect(config).to eq("test")
      end
    end

    context "when config file is not present" do
      it "returns nil" do
        api = double(:github_api)
        api.stub(:file_contents).and_raise(Octokit::NotFound)
        pull_request = pull_request(api)

        config = pull_request.config

        expect(config).to be_nil
      end
    end
  end

  def pull_request(api)
    payload = double(
      :payload,
      number: 1,
      full_repo_name: "org/repo",
      head_sha: "abc123"
    )
    GithubApi.stub(new: api)
    PullRequest.new(payload, "gh-token")
  end
end
