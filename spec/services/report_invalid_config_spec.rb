require "rails_helper"

describe ReportInvalidConfig do
  describe ".call" do
    context "given a custom message" do
      it "reports the file as an invalid config file to GitHub" do
        commit_status = stubbed_commit_status(:set_config_error)
        stubbed_build(repo_name: "houndci/hound")
        pull_request_number = "42"
        commit_sha = "abc123"
        message = "Invalid ruby file, woff"

        ReportInvalidConfig.call(
          pull_request_number: pull_request_number,
          commit_sha: commit_sha,
          message: message,
        )

        expect(commit_status).to have_received(:set_config_error).with(message)
        expect(Build).to have_received(:find_by!).with(
          pull_request_number: pull_request_number,
          commit_sha: commit_sha,
        )
      end
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
    build = double("Build", user_token: "sekkrit")
    allow(Build).to receive(:find_by!).and_return(build)

    methods.each do |method_name, return_value|
      allow(build).to receive(method_name).and_return(return_value)
    end

    build
  end
end
