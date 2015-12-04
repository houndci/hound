class Mailer < ActionMailer::Base
  default from: "Hound <hound@thoughtbot.com>".freeze

  def repo_activation_notification(repo, username, email)
    @repo = repo
    @subscriber = repo.subscriber
    @username = username

    mail(
      to: email,
      subject: "Hound is now enabled on #{repo.full_github_name} repository",
    )
  end
end
