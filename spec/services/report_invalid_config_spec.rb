require "rails_helper"

describe ReportInvalidConfig do
  describe ".run" do
    it "reports the file as an invalid config file to Github" do
      stub_const("Hound::GITHUB_TOKEN", "sometoken")
      commit_status = stubbed_commit_status(:set_config_error)
      stubbed_build(repo_name: "thoughtbot/hound")
      pull_request_number = "42"
      commit_sha = "abc123"
      filename = "config/.rubocop.yml"

      ReportInvalidConfig.run(
        pull_request_number: pull_request_number,
        commit_sha: commit_sha,
        filename: filename,
      )

      expect(commit_status).to have_received(:set_config_error).with(filename)
      expect(Build).to have_received(:find_by!).with(
        pull_request_number: pull_request_number,
        commit_sha: commit_sha,
      )
    end
  end

  def stubbed_commit_status(*methods)
    commit_status = double("CommitStatus")
    allow(CommitStatus).to receive(:new).and_return(commit_status)

    methods.each do |method_name|
      allow(commit_status).to receive(method_name)
    end

    commit_status
  end

  def stubbed_build(methods = {})
    build = double("Build")
    allow(Build).to receive(:find_by!).and_return(build)

    methods.each do |method_name, return_value|
      allow(build).to receive(method_name).and_return(return_value)
    end

    build
  end
end
