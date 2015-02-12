class OrgInvitationJob
  extend Retryable

  @queue = :high

  def self.perform(github_token)
    github = GithubApi.new(github_token)
    github.accept_pending_invitations
  rescue Resque::TermException
    Resque.enqueue(self)
  end
end
