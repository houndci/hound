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

  describe "#github_token" do
    context "when user's can reach the repo" do
      it "returns the user's token" do
        user = create(:user, token: "sometoken")
        repo = create(:repo, users: [user])
        build = create(:build, repo: repo)
        github_api = instance_double("GitHubApi", repository?: true)
        allow(GitHubApi).to receive(:new).and_return(github_api)

        expect(build.github_token).to eq user.token
      end
    end

    context "when user's cannot reach the repo" do
      it "returns the houndci's token" do
        user = create(:user, token: "sometoken")
        repo = create(:repo, users: [user])
        build = create(:build, repo: repo)
        github_api = instance_double("GitHubApi", repository?: false)
        allow(GitHubApi).to receive(:new).and_return(github_api)

        expect(build.github_token).to eq Hound::GITHUB_TOKEN
      end
    end
  end

  describe "#review_errors" do
    it "returns a list of unique linter errors" do
      file_review1 = create(:file_review, error: "invalid config\n some file1")
      file_review2 = create(:file_review, error: "invalid config\n some file2")
      file_review3 = create(:file_review, error: "rule is invalid\n some file1")
      file_reviews = [file_review1, file_review2, file_review3]
      build = create(:build, file_reviews: file_reviews)

      result = build.review_errors

      expect(result.size).to eq 2
      expect(result.first).to start_with("invalid config")
      expect(result.second).to start_with("rule is invalid")
    end
  end
end
