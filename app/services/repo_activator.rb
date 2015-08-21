class RepoActivator
  attr_reader :errors

  def initialize(github_token:, repo:)
    @github_token = github_token
    @repo = repo
    @errors = []
  end

  def activate
    activate_repo.tap { enqueue_org_invitation }
  end

  def deactivate
    deactivate_repo
  end

  private

  attr_reader :github_token, :repo

  def activate_repo
    change_repository_state_quietly do
      add_hound_to_repo && create_webhook && repo.activate
    end
  end

  def deactivate_repo
    change_repository_state_quietly do
      remove_hound_from_repo
      delete_webhook && repo.deactivate
    end
  end

  def change_repository_state_quietly
    yield
  rescue Octokit::Error => error
    add_error(error)
    Raven.capture_exception(error)
    false
  end

  def remove_hound_from_repo
    RemoveHoundFromRepo.run(repo.full_github_name, github)
  end

  def add_hound_to_repo
    AddHoundToRepo.run(repo.full_github_name, github)
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
    if repo.in_organization?
      AcceptOrgInvitationsJob.perform_later
    end
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

  def add_error(error)
    error_message = ErrorMessageTranslation.from_error_response(error)
    errors.push(error_message).compact!
  end
end
