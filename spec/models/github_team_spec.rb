require "fast_spec_helper"
require "app/models/github_team"

describe GithubTeam do
  describe "#add_repo" do
    context "when the team has pull permission" do
      it "updates the permission to push" do
        id = 1234
        team = double("OctoKitTeam", permission: pull_permission, id: id)
        github = double("Github", update_team: true, add_repo_to_team: true)
        github_team = GithubTeam.new(team, github)

        github_team.add_repo(repo_name)

        expect(github).to have_received(:update_team).
          with(id, permission: "push")
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

      expect(github).to have_received(:remove_repo_from_team).
        with(id, repo_name)
    end
  end

  describe "#remove_user" do
    it "calls github with the team id and passed username" do
      id = 1234
      team = double("OctoKitTeam", id: id, permission: non_pull_permission)
      github = double(
        "Github",
        team_repos: [],
        remove_user_from_team: true
      )
      github_team = GithubTeam.new(team, github)

      github_team.remove_user(username)

      expect(github).to have_received(:remove_user_from_team).
        with(id, username)
    end
  end

  describe "#add_user" do
    it "calls github with the team id and passed username" do
      id = 1234
      team = double("OctoKitTeam", id: id, permission: non_pull_permission)
      github = double(
        "Github",
        add_user_to_team: true
      )
      github_team = GithubTeam.new(team, github)

      github_team.add_user(username)

      expect(github).to have_received(:add_user_to_team).
        with(id, username)
    end
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

  def username
    "houndci"
  end
end
