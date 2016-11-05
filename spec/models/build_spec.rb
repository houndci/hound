require "rails_helper"

describe Build do
  describe "associations" do
    it { should belong_to :repo }
    it { should have_many(:file_reviews).dependent(:destroy) }
    it { should have_many(:violations).through(:file_reviews) }
  end

  describe "validations" do
    it { should validate_presence_of :repo }
  end

  context "on create" do
    it "generates a UUID" do
      build = create(:build)

      expect(build.uuid).to be_present
    end
  end

  describe "#user_token" do
    context "when user is associated with a build" do
      it "returns the user's token" do
        user = build(:user, token: "sometoken")
        build = build(:build, user: user)

        expect(build.user_token).to eq user.token
      end
    end

    context "when user is not associated" do
      it "returns the houndci's token" do
        build = build(:build)

        expect(build.user_token).to eq Hound::GITHUB_TOKEN
      end
    end
  end
end
