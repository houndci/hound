require "rails_helper"

RSpec.describe Mailer do
  describe "#repo_activation_notification" do
    context "given a private repository" do
      it "builds correct email for sending" do
        subscription = create(:subscription)
        repo = subscription.repo

        mail = Mailer.repo_activation_notification(
          repo,
          "github_username",
          "user@example.com",
        )

        expect(mail.from).to eq ["hound@thoughtbot.com"]
        expect(mail.to).to eq ["user@example.com"]
        expect(mail.subject).to eq(
          "Hound is now enabled on #{repo.full_github_name} repository",
        )
        expect(mail.body).to include "github_username"
        expect(mail.body).to include repo.full_github_name
        expect(mail.body).to include "@#{repo.subscriber.github_username}"
        expect(mail.body).to include subscription.user.email_address
      end
    end

    context "given a public repository" do
      it "builds correct email for sending" do
        repo = create(:repo)

        mail = Mailer.repo_activation_notification(
          repo,
          "github_username",
          "user@example.com",
        )

        expect(mail.from).to eq ["hound@thoughtbot.com"]
        expect(mail.to).to eq ["user@example.com"]
        expect(mail.subject).to eq(
          "Hound is now enabled on #{repo.full_github_name} repository",
        )
        expect(mail.body).to include "github_username"
        expect(mail.body).to include repo.full_github_name
        expect(mail.body).not_to include "purchased the subscription"
      end
    end
  end
end
