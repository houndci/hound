class AcceptOrgInvitationsJob
  extend Retryable

  @queue = :high

  def self.perform
    github = GithubApi.new(ENV["HOUND_GITHUB_TOKEN"])
    github.accept_pending_invitations
  rescue Resque::TermException
    Resque.enqueue(self)
  rescue => exception
    Raven.capture_exception(exception, {})
  end
end
