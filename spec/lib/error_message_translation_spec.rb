require "spec_helper"
require "lib/error_message_translation"

describe ErrorMessageTranslation do
  describe ".from_error_response" do
    context "when error status is 403" do
      it "returns error message" do
        error = double("error", message: octokit_403_error_message)
        expected_message = "You must be an admin to add a team membership."

        result = ErrorMessageTranslation.from_error_response(error)

        expect(result).to eq expected_message
      end
    end

    context "when error status is not 403" do
      it "returns nil" do
        error = double("error", message: octokit_400_error_message)

        result = ErrorMessageTranslation.from_error_response(error)

        expect(result).to be_nil
      end
    end

    context "when error does not adhere to expected formatting" do
      it "returns nil" do
        message = "error"
        error = double("error", message: message)

        result = ErrorMessageTranslation.from_error_response(error)

        expect(result).to be_nil
      end
    end

    context "when error related to adding more GitHub seats" do
      it "returns a helpful message" do
        error = double("error", message: octokit_422_error_message)

        result = ErrorMessageTranslation.from_error_response(error)

        expect(result).to(
          eq("Please add a GitHub seat to enable Hound. https://help.github.com/articles/adding-seats-to-your-organization"),
        )
      end
    end
  end

  private

  def octokit_403_error_message
    "PUT https://api.github.com/teams/3675/memberships/houndci: 403 - You must be an admin to add a team membership. // See: https://developer.github.com/v3"
  end

  def octokit_400_error_message
    "PUT https://api.github.com/teams/3675/memberships/houndci: 400 - Problems parsing JSON. // See: https://developer.github.com/v3"
  end

  def octokit_422_error_message
    <<~ERROR
      Octokit::UnprocessableEntity: PUT https://api.github.com/repos/safeguardingmonitor/platform/collaborators/houndci-bot: 422 - Validation Failed
      Error summary:
        resource: Repository
        code: custom
        message: You must purchase at least one more seat to add this user as a collaborator. // See: https://developer.github.com/v3/repos/collaborators/#add-user-as-a-collaborator
    ERROR
  end
end
