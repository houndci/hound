class OrgInvitationJob < ActiveJob::Base
  extend Retryable

  queue_as :high

  def perform
    github = GithubApi.new
    github.accept_pending_invitations
  rescue Resque::TermException
    Resque.enqueue(self)
  end
end
