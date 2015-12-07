class CollaboratorNotifier
  def initialize(repo:, github_token:)
    @repo = repo
    @github_token = github_token
  end

  def notify(collaborator)
    user = User.find_by_github_username(collaborator[:login])

    if user
      notify_hound_user(user)
    else
      notify_guest(collaborator)
    end
  end

  private

  attr_reader :github_token, :repo

  def notify_hound_user(user)
    if user.token != github_token
      queue_email_for_delivery(
        github_username: user.github_username,
        email: user.email_address,
      )
    end
  end

  def notify_guest(collaborator)
    github_user = github.user(collaborator[:login])

    if github_user[:email].present?
      queue_email_for_delivery(
        github_username: github_user[:login],
        email: github_user[:email],
      )
    end
  end

  def queue_email_for_delivery(github_username:, email:)
    Mailer.
      repo_activation_notification(repo, github_username, email).
      deliver_later
  end

  def github
    @github ||= GithubApi.new(github_token)
  end
end
