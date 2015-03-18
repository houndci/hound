require "spec_helper"
require "app/models/github_team"

describe GithubTeam do
  let(:non_pull_permission) { "either push or admin" }
  let(:pull_permission) { "pull"}
  let(:repo_name) { "foo/bar" }
  let(:username) { "houndci" }

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

      result = github_team.remove_user(username)

      expect(result).to eq true
      expect(github).to have_received(:remove_user_from_team).
        with(id, username)
    end

    context "when team still has repos" do
      it "does not remove the user" do
        id = 1234
        team = double("OctoKitTeam", id: id, permission: non_pull_permission)
        github = double(
          "Github",
          team_repos: [double("Repo")],
          remove_user_from_team: true
        )
        github_team = GithubTeam.new(team, github)

        github_team.remove_user(username)

        expect(github).not_to have_received(:remove_user_from_team).
          with(id, username)
      end
    end
  end

  describe "#add_user" do
    it "calls github with the team id and passed username" do
      id = 1234
      team = double("OctoKitTeam", id: id, permission: non_pull_permission)
      github = double("Github", add_user_to_team: true)
      github_team = GithubTeam.new(team, github)

      github_team.add_user(username)

      expect(github).to have_received(:add_user_to_team).
        with(id, username)
    end
  end
end
