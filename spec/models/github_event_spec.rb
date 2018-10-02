require "rails_helper"

RSpec.describe GitHubEvent do
  describe "#process" do
    context "with marketplace purchase" do
      context "when purchased" do
        it "updates owner's marketplace plan" do
          body = {
            "action" => "purchased",
            "marketplace_purchase" => {
              "account" => {
                "id" => 12345,
                "login" => "foo",
                "type" => GitHubApi::ORGANIZATION_TYPE,
              },
              "plan" => {
                "id" => 67890,
              },
            },
          }
          event = described_class.new(
            type: GitHubEvent::MARKETPLACE_PURCHASE,
            body: body,
          )

          event.process

          owner = Owner.find_by(name: "foo")
          expect(owner).to have_attributes(
            marketplace_plan_id: body["marketplace_purchase"]["plan"]["id"],
          )
        end
      end
    end

    context "with pull request" do
      context "when opened" do
        it "runs the build" do
          body = JSON.parse(read_fixture("pull_request_opened_event.json"))
          event = described_class.new(
            type: GitHubEvent::PULL_REQUEST,
            body: body,
          )
          allow(BuildRunner).to receive(:call)

          run_background_jobs_immediately do
            event.process
          end

          expect(BuildRunner).to have_received(:call)
        end
      end
    end

    context "for a cancellation" do
      it "deactivates the owner's repos" do
        owner = create(:owner, github_id: 123456, name: "salbertson")
        public_repo = create(:repo, :active, owner: owner)
        private_repo = create(:repo, :active, :private, owner: owner)
        body = JSON.parse(
          read_fixture("github_marketplace_purchase_cancelled.json"),
        )
        event = described_class.new(
          type: GitHubEvent::MARKETPLACE_PURCHASE,
          body: body,
        )

        event.process

        expect(public_repo.reload).not_to be_active
        expect(private_repo.reload).not_to be_active
      end
    end

    context "for an App uninstall" do
      it "disables the repos controlled by the installation" do
        owner = create(:owner, github_id: 1, name: "octocat")
        repo = create(:repo, :active, owner: owner, installation_id: 2)
        body = JSON.parse(read_fixture("github_app_uninstall.json"))
        event = described_class.new(
          type: GitHubEvent::INSTALLATION,
          body: body,
        )

        event.process

        expect(repo.reload).not_to be_active
      end

      it "removes the installation id from repos" do
        owner = create(:owner, github_id: 1, name: "octocat")
        repo = create(:repo, :active, owner: owner, installation_id: 2)
        body = JSON.parse(read_fixture("github_app_uninstall.json"))
        event = described_class.new(
          type: GitHubEvent::INSTALLATION,
          body: body,
        )

        event.process

        expect(repo.reload.installation_id).to be_nil
      end

      it "removes the installation id from user"
    end

    context "when repos are added to an installation" do
      it "add installation id to the repos"
    end

    context "when repos are removed from an installation" do
      it "removes installation id from the repos"
    end
  end
end
