require "rails_helper"

describe CollaboratorNotifier do
  describe "#run" do
    let(:repo) { build(:repo) }
    let(:mail) { double(deliver_later: true) }
    let(:github_token) { "github_token" }
    let(:github_api) { double.as_null_object }
    let(:notifier) do
      CollaboratorNotifier.new(repo: repo, github_token: github_token)
    end

    before do
      allow(GithubApi).to receive(:new).and_return(github_api)
      allow(Mailer).to receive(:repo_activation_notification).and_return(mail)
    end

    context "when collaborator is on Hound" do
      it "sends a notification using their email address" do
        user = create(:user, github_username: "salbertson")

        notifier.run login: "salbertson"

        expect(Mailer).to have_received(:repo_activation_notification).
          with(repo, user.github_username, user.email_address)
        expect(mail).to have_received(:deliver_later)
      end
    end

    context "when collaborator is not on Hound" do
      context "when collaborator has public GitHub email address" do
        it "sends a notification using their GitHub public email address" do
          allow(github_api).to receive(:user).
            and_return(login: "salbertson", email: "salbertson@example.com")

          notifier.run login: "salbertson"

          expect(github_api).to have_received(:user).with("salbertson")
          expect(Mailer).to have_received(:repo_activation_notification).
            with(repo, "salbertson", "salbertson@example.com")
          expect(mail).to have_received(:deliver_later)
        end
      end

      context "when collaborator has no public GitHub email address" do
        it "does nothing" do
          allow(github_api).to receive(:user).and_return(email: nil)

          notifier.run login: "salbertson"

          expect(github_api).to have_received(:user).with("salbertson")
          expect(Mailer).not_to have_received(:repo_activation_notification)
        end
      end
    end

    context "when the collaborator and activator is the same person" do
      it "does not send a notification to that user" do
        create(:user, github_username: "salbertson", token: github_token)

        notifier.run login: "salbertson"

        expect(Mailer).not_to have_received(:repo_activation_notification)
      end
    end
  end
end
