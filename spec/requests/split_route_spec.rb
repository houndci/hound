require "rails_helper"

describe "/split" do
  context "without auth" do
    it "does not allow access" do
      get "/split"

      expect(response.status).to eq(401)
    end
  end

  context "with auth" do
    it "allows access" do
      credentials = ActionController::HttpAuthentication::Basic.
        encode_credentials(
          "admin",
          ENV["SPLIT_ADMIN_PASSWORD"]
        )
      get "/split", nil, { "HTTP_AUTHORIZATION" => credentials }

      expect(response.status).to eq(200)
    end
  end
end
