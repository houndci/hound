require "spec_helper"

describe ReposController do
  describe "#index" do
    context "when current user does not have an email address saved" do
      it "pushes an email address job onto queue" do
        user = create(:user, email_address: nil)
        stub_sign_in(user)
        allow(JobQueue).to receive(:push)

        get :index, format: :json

        expect(JobQueue).to have_received(:push).with(
          EmailAddressJob,
          user.id,
          AuthenticationHelper::GITHUB_TOKEN
        )
      end
    end

    context "when current user has an email address saved" do
      it "does not push an email address job onto queue" do
        user = create(:user, email_address: "test@example.com")
        stub_sign_in(user)
        allow(JobQueue).to receive(:push)

        get :index, format: :json

        expect(JobQueue).not_to have_received(:push)
      end
    end

    context "when current user is a member of a repo with missing information" do
      it "clears all memberships to allow for a forced reload" do
        user = create(:user, :with_email)
        repo = create(:repo, in_organization: nil, private: nil)
        user.repos << repo
        stub_sign_in(user)

        get :index, format: :json

        expect(user.repos.size).to eq(0)
      end
    end

    context "when current user is a member of a repo with no missing information" do
      it "clears all memberships to allow for a forced reload" do
        user = create(:user, :with_email)
        repo = create(:repo, in_organization: true, private: true)
        user.repos << repo
        stub_sign_in(user)

        get :index, format: :json

        expect(user.repos.size).to eq(1)
      end
    end
  end
end
