require "rails_helper"

RSpec.describe ActivationsController do
  let!(:membership) { create(:membership) }
  let!(:repo) { membership.repo }

  describe "POST #create" do
    context "when activation succeeds" do
      let(:expected_repo_json) do
        RepoSerializer.new(
          repo,
          scope_name: :current_user,
          scope: membership.user,
        ).to_json
      end
      let(:activator) { double("RepoActivator", activate: true, errors: []) }

      before do
        allow(RepoActivator).to receive(:new).and_return(activator)
        stub_sign_in(membership.user)
      end

      it "returns successful response" do
        post :create, params: { repo_id: repo.id }, format: :json
        expect(response).to have_http_status(:created)
        expect(response.body).to eq expected_repo_json
        expect(activator).to have_received(:activate)
        expect(RepoActivator).to have_received(:new).
          with(repo: repo, github_token: membership.user.token)
      end
    end

    context "when activation fails" do
      context "due to 403 Forbidden from GitHub, RA errors present" do
        let(:error_message) { "You must be an admin to add a team membership" }
        let(:activator) do
          double(
            "RepoActivator",
            activate: false,
            errors: [error_message],
          )
        end

        before do
          stub_sign_in(membership.user)
          allow(RepoActivator).to receive(:new).and_return(activator)
        end

        it "returns error response" do
          post :create, params: { repo_id: repo.id }, format: :json
          parsed_response = JSON.parse(response.body)
          expect(response.code).to eq "502"
          expect(parsed_response["errors"]).to match_array(error_message)
          expect(activator).to have_received(:activate)
          expect(RepoActivator).to have_received(:new).
            with(repo: repo, github_token: membership.user.token)
        end
      end
    end

    context "due to 403 Forbidden from GitHub, RA errors not present" do
      let!(:activator) { double("RepoActivator", activate: false, errors: []) }

      before do
        allow(RepoActivator).to receive(:new).and_return(activator)
        stub_sign_in(membership.user)
      end

      it "tracks failed activation" do
        post :create, params: { repo_id: repo.id }, format: :json

        expect(analytics).to have_tracked("Repo Activation Failed").
          for_user(membership.user).
          with(
            properties: {
              name: repo.name,
              private: false,
            }
          )
      end
    end

    context "when repo is not public" do
      let(:user) { create(:user) }
      let(:repo) { create(:repo, private: true) }
      let(:activator) { double("RepoActivator", activate: false) }

      before do
        user.repos << repo
        allow(RepoActivator).to receive(:new).and_return(activator)
        stub_sign_in(user)
      end

      it "does not activate" do
        expect { post :create, params: { repo_id: repo.id }, format: :json }.
          to raise_error(ActivationsController::CannotActivatePaidRepo)
        expect(activator).not_to have_received(:activate)
      end
    end
  end
end
