class AcceptOrgInvitationsJob < ActiveJob::Base
  extend Retryable

  queue_as :high

  def perform
    github = GithubApi.new(ENV["HOUND_GITHUB_TOKEN"])
    github.accept_pending_invitations
  rescue Resque::TermException
    retry_job
  end
end
