require "fast_spec_helper"
require "app/models/github_team"

describe GithubTeam do
  describe "#has_pull_permission?" do
    it "returns true when team#permission is 'pull'" do
      team = double("OctoKitTeam", permission: pull_permission)
      github = double("Github")
      github_team = GithubTeam.new(team, github)

      expect(github_team.has_pull_permission?).to be true
    end

    it "returns false when team#permission is not pull" do
      team = double("OctoKitTeam", permission: non_pull_permission)
      github = double("Github")
      github_team = GithubTeam.new(team, github)

      expect(github_team.has_pull_permission?).to be false
    end
  end

  describe "#id" do
    it "delegates id to team" do
      id = 1234
      team = double("OctoKitTeam", id: id)
      github = double("Github")
      github_team = GithubTeam.new(team, github)

      expect(github_team.id).to be id
    end
  end

  describe "#add_repo" do
    context "when the team has pull permission" do
      it "updates the permission to push" do
        id = 1234
        team = double("OctoKitTeam", permission: pull_permission, id: id)
        github = double("Github", update_team: true, add_repo_to_team: true)
        github_team = GithubTeam.new(team, github)

        github_team.add_repo(repo_name)

        expect(github).to have_received(:update_team)
          .with(id, permission: "push")
      end
    end

    context "when the team does not have pull permission" do
      it "will not update team permission" do
        id = 1234
        team = double("OctoKitTeam", permission: non_pull_permission, id: id)
        github = double("Github", update_team: true, add_repo_to_team: true)
        github_team = GithubTeam.new(team, github)

        github_team.add_repo(repo_name)

        expect(github).not_to have_received(:update_team)
      end
    end

    it "calls github with the team id and passed repo name" do
      id = 1234
      team = double("OctoKitTeam", id: id, permission: non_pull_permission)
      github = double("Github", add_repo_to_team: true)
      github_team = GithubTeam.new(team, github)

      github_team.add_repo(repo_name)

      expect(github).to have_received(:add_repo_to_team).with(id, repo_name)
    end
  end

  describe "#remove_repo" do
    it "calls github with the team id and passed repo name" do
      id = 1234
      team = double("OctoKitTeam", id: id, permission: non_pull_permission)
      github = double("Github", remove_repo_from_team: true)
      github_team = GithubTeam.new(team, github)

      github_team.remove_repo(repo_name)

      expect(github).to have_received(:remove_repo_from_team).with(id, repo_name)
    end
  end

  describe "#remove_user" do
  end

  def non_pull_permission
    "either push or admin"
  end

  def pull_permission
    "pull"
  end

  def repo_name
    "foo/bar"
  end
end
