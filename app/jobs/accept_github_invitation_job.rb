class AcceptGitHubInvitationJob < ApplicationJob
  queue_as :high

  def perform(repo_name)
    unless hound_github.repository?(repo_name)
      hound_github.accept_invitation(repo_name)
    end
  end

  private

  def hound_github
    @_hound_github ||= GitHubApi.new(Hound::GITHUB_TOKEN)
  end
end
