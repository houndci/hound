class RepoActivator
  def initialize(github_token:, repo:)
    @github_token = github_token
    @repo = repo
  end

  def activate
    activate_repo && enqueue_org_invitation
  end

  def deactivate
    change_repository_state_quietly do
      delete_webhook && repo.deactivate
    end
  end

  private

  attr_reader :github_token, :repo

  def activate_repo
    change_repository_state_quietly do
      add_hound_to_repo && create_webhook && repo.activate
    end
  end

  def change_repository_state_quietly
    yield
  rescue Octokit::Error => error
    Raven.capture_exception(error)
    false
  end

  def add_hound_to_repo
    github_username = ENV.fetch("HOUND_GITHUB_USERNAME")
    github.add_user_to_repo(github_username, repo.full_github_name)
  end

  def github
    @github ||= GithubApi.new(github_token)
  end

  def create_webhook
    github.create_hook(repo.full_github_name, builds_url) do |hook|
      repo.update(hook_id: hook.id)
    end
  end

  def enqueue_org_invitation
    OrgInvitationJob.perform_later
  end

  def delete_webhook
    github.remove_hook(repo.full_github_name, repo.hook_id) do
      repo.update(hook_id: nil)
    end
  end

  def builds_url
    URI.join("#{protocol}://#{ENV["HOST"]}", "builds").to_s
  end

  def protocol
    if ENV.fetch("ENABLE_HTTPS") == "yes"
      "https"
    else
      "http"
    end
  end
end
