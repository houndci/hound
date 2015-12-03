class Mailer < ActionMailer::Base
  def repo_activation_notification(repo, username, email)
    @repo = repo
    @subscriber = repo.subscriber
    @username = username

    mail(
      from: "hound@thoughtbot.com",
      to: email,
      subject:
        "[Hound] Hound is now enabled on #{repo.full_github_name} repository"
    )
  end
end
