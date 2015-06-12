require "rails_helper"

describe AccountsController do
  context "updating billable email" do
    context "when email is not provided" do
      it "raises" do
        user = create(:user, stripe_customer_id: "customer-id")
        stub_sign_in(user)

        expect do
          patch :update, billable_email: "", format: :json
        end.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when email is provided" do
      context "on success" do
        it "returns updated account" do
          new_email = "new-email@example.com"
          customer_id = "customer-id"
          user = create(:user, stripe_customer_id: customer_id)
          stub_sign_in(user)
          stub_customer_find_request(customer_id)
          stub_customer_update_request(email: new_email)

          patch :update, billable_email: new_email, format: :json

          response_body = JSON.parse(response.body)
          expect(response_body["billable_email"]).to eq new_email
        end
      end
    end

    context "on failure" do
      it "returns 502 Bad Gateway" do
        new_email = "new-email@example.com"
        customer_id = "customer-id"
        user = create(:user, stripe_customer_id: customer_id)
        stub_sign_in(user)
        stub_customer_find_request(customer_id)
        stub_failed_customer_update_request(email: new_email)

        patch :update, billable_email: new_email, format: :json

        expect(response).to have_http_status(:bad_gateway)
      end
    end
  end
end
