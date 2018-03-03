# frozen_string_literal: true

module Buildable
  def perform(payload_data)
    payload = Payload.new(payload_data)

    unless blacklisted?(payload)
      UpdateRepoStatus.call(payload)
      BuildRunner.call(payload)
    end
  end

  def after_retry_exhausted
    payload = Payload.new(*arguments)
    build_runner = BuildRunner.new(payload)
    build_runner.set_internal_error
  end

  private

  def blacklisted?(payload)
    BlacklistedPullRequest.where(
      full_repo_name: payload.full_repo_name,
      pull_request_number: payload.pull_request_number,
    ).any?
  end
end
