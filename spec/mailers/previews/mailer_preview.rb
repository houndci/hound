class MailerPreview < ActionMailer::Preview
  def repo_activation_notification
    Mailer.repo_activation_notification(
      Repo.first,
      "github_username",
      "user@example.com"
    )
  end
end
