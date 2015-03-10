require "rails_helper"

describe AccountsController do
  context "updating billable email" do
    context "when email is not provided" do
      it "returns 422 Unprocessable Entity" do
        user = create(:user, stripe_customer_id: "customer-id")
        stub_sign_in(user)

        patch :update, billable_email: "", format: :json

        response_body = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body["errors"].first).
          to eq I18n.t("account.billable_email.invalid")
      end

      context "when email is not valid" do
        it "returns 422 Unprocessable Entity" do
          user = create(:user, stripe_customer_id: "customer-id")
          invalid_email = "newemail"
          stub_sign_in(user)

          patch :update, billable_email: invalid_email, format: :json

          response_body = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response_body["errors"].first).
            to eq I18n.t("account.billable_email.invalid")
        end
      end
    end

    context "when email is provided" do
      context "on success" do
        it "returns ok status" do
          new_email = "new-email@example.com"
          customer_id = "customer-id"
          user = create(:user, stripe_customer_id: customer_id)
          stub_sign_in(user)
          stub_customer_find_request(customer_id)
          update_request = stub_customer_update_request(email: new_email)

          patch :update, billable_email: new_email, format: :json

          expect(response).to be_ok
          expect(update_request).to have_been_requested
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
