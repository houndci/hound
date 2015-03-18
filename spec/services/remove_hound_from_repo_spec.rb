require "rails_helper"
require "app/services/manage_hound"
require "app/services/remove_hound_from_repo"

describe RemoveHoundFromRepo do
  describe "#run" do
    context "when repo is not part of an organization" do
      it "removes user from repo" do
        repo_name = "foo/bar"
        github_repo = double("GithubRepo", organization: false)
        github =
          double("GithubApi", repo: github_repo, remove_collaborator: nil)

        RemoveHoundFromRepo.run(repo_name, github)

        expect(github).to have_received(:remove_collaborator).
          with(repo_name, hound_github_username)
      end
    end

    context "with org repo" do
      context "when the services team does not exist" do
        it "doesn't remove hound from the repo or team" do
          repo_name = "foo/bar"
          github_repo =
            double("GithubRepo", organization: double(login: "foo"))
          github = double(
            "GithubApi",
            repo: github_repo,
            remove_repo_from_team: true,
            remove_user_from_team: true,
            org_teams: [],
          )

          expect(RemoveHoundFromRepo.run(repo_name, github)).to be nil
          expect(github).to have_received(:org_teams).with("foo")
          expect(github).not_to have_received(:remove_repo_from_team)
          expect(github).not_to have_received(:remove_user_from_team)
        end
      end

      context "when team exists" do
        context "team has only one repo" do
          it "will remove hound user from team" do
            team_id = 222
            github_team =
              double("RepoTeams", id: team_id, name: "Services")
            repo_name = "foo/bar"
            github_repo =
              double("GithubRepo", organization: double(login: "foo"))
            github = double(
              "GithubApi",
              repo: github_repo,
              org_teams: [github_team],
              remove_repo_from_team: true,
              remove_user_from_team: true,
              team_repos: double("TeamRepos", empty?: true),
            )

            RemoveHoundFromRepo.run(repo_name, github)

            expect(github).to have_received(:org_teams).with("foo")
            expect(github).
              to have_received(:remove_repo_from_team).with(team_id, repo_name)
            expect(github).to have_received(:remove_user_from_team).
              with(team_id, hound_github_username)
          end
        end

        context "team has multiple repos" do
          it "will not remove user from team" do
            team_id = 222
            github_team =
              double("RepoTeams", id: team_id, name: "Services")
            repo_name = "foo/bar"
            github_repo =
              double("GithubRepo", organization: double(login: "foo"))
            github = double(
              "GithubApi",
              repo: github_repo,
              org_teams: [github_team],
              remove_repo_from_team: true,
              remove_user_from_team: true,
              team_repos: double("TeamRepos", empty?: false),
            )

            RemoveHoundFromRepo.run(repo_name, github)

            expect(github).to have_received(:org_teams).with("foo")
            expect(github).
              to have_received(:remove_repo_from_team).with(team_id, repo_name)
            expect(github).
              not_to have_received(:remove_user_from_team)
          end

          it "will remove repo from team" do
            team_id = 222
            github_team =
              double("RepoTeams", id: team_id, name: "Services")
            repo_name = "foo/bar"
            github_repo =
              double("GithubRepo", organization: double(login: "foo"))
            github = double(
              "GithubApi",
              repo: github_repo,
              org_teams: [github_team],
              remove_repo_from_team: true,
              team_repos: double("TeamRepos", empty?: false),
            )

            RemoveHoundFromRepo.run(repo_name, github)

            expect(github).to have_received(:org_teams).with("foo")
            expect(github).
              to have_received(:remove_repo_from_team).with(team_id, repo_name)
          end
        end
      end
    end
  end

  def hound_github_username
    ENV["HOUND_GITHUB_USERNAME"]
  end
end
