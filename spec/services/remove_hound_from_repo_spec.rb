require "fast_spec_helper"
require "app/services/remove_hound_from_repo"

describe RemoveHoundFromRepo do
  describe "#run" do
    context "with org repo" do

    end

    context "when repo is not part of an organization" do
      it "removes user from repo" do
        repo_name = "foo/bar"
        github_repo = double("GithubRepo", organization: false)
        github = double("GithubApi", repo: github_repo, remove_collaborator: nil)

        RemoveHoundFromRepo.run(repo_name, github)

        expect(github).to have_received(:remove_collaborator).
          with(repo_name, hound_github_username)
      end
    end
  end

  private

  def hound_github_username
    ENV["HOUND_GITHUB_USERNAME"]
  end
end
