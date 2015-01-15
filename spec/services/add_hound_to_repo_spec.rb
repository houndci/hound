require "fast_spec_helper"
require "app/services/add_hound_to_repo"
require "app/models/github_user"

describe AddHoundToRepo do
  describe "#run" do
    context "with org repo" do
      context "when repo is part of a team" do
        context "when request succeeds" do
          it "adds Hound user to first repo team with admin access" do
            github_team_id = 1001
            github = build_github(github_team_id: github_team_id)
            allow(github).to receive(:add_user_to_team).and_return(true)

            result = AddHoundToRepo.run("foo/bar", github)

            expect(result).to eq true
            expect(github).to have_received(:add_user_to_team).
              with(hound_github_username, github_team_id)
          end
        end

        context "when request fails" do
          it "returns false" do
            github = build_github
            allow(github).to receive(:add_user_to_team).and_return(false)

            result = AddHoundToRepo.run("foo/bar", github)

            expect(result).to eq false
          end
        end
      end

      context "when repo is not part of a team" do
        context "when Services team does not exist" do
          it "adds hound to new Services team" do
            repo_name = "foo/bar"
            github_team = double("GithubTeam", id: 1001)
            github = build_github
            allow(github).to receive(:user_teams).and_return([])
            allow(github).to receive(:org_teams).and_return([])
            allow(github).to receive(:add_user_to_team)
            allow(github).to receive(:create_team).and_return(github_team)

            AddHoundToRepo.run(repo_name, github)

            expect(github).to have_received(:create_team).with(
              org_name: "foo",
              team_name: AddHoundToRepo::SERVICES_TEAM_NAME,
              repo_name: repo_name
            )
            expect(github).to have_received(:add_user_to_team).
              with(hound_github_username, github_team.id)
          end
        end

        context "when Services team exists" do
          it "adds user to existing Services team" do
            github_team_id = 1001
            github = build_github(github_team_id: github_team_id)
            allow(github).to receive(:add_user_to_team)

            AddHoundToRepo.run("foo/bar", github)

            expect(github).to have_received(:add_user_to_team).
              with(hound_github_username, github_team_id)
          end

          context "when team name is lowercase" do
            it "adds user to the team" do
              github_team_id = 1001
              github = build_github(github_team_id: github_team_id)
              allow(github).to receive(:add_user_to_team)

              AddHoundToRepo.run("foo/bar", github)

              expect(github).to have_received(:add_user_to_team).
                with(hound_github_username, github_team_id)
            end
          end
        end
      end

      context "when Services team has pull access" do
        it "updates permissions to push access" do
          github_team =
            double("RepoTeams", id: 222, name: "Services", permission: "pull")
          github = build_github
          allow(github).to receive(:add_user_to_team)
          allow(github).to receive(:user_teams).and_return([])
          allow(github).to receive(:org_teams).and_return([github_team])
          allow(github).to receive(:update_team)
          allow(github).to receive(:add_repo_to_team)

          AddHoundToRepo.run("foo/bar", github)

          expect(github).to have_received(:update_team).
            with(github_team.id, permission: "push")
        end
      end
    end

    context "when repo is not part of an organization" do
      it "adds user as collaborator" do
        repo_name = "foo/bar"
        github_repo = double("GithubRepo", organization: false)
        github = double("GithubApi", repo: github_repo, add_collaborator: nil)

        AddHoundToRepo.run(repo_name, github)

        expect(github).to have_received(:add_collaborator).
          with(repo_name, hound_github_username)
      end
    end
  end

  def build_github(github_team_id: 10)
    github_team = double("GithubTeam", id: github_team_id, permission: "admin")
    github_repo = double("GithubRepo", organization: double(login: "foo"))
    double(
      "GithubApi",
      repo: github_repo,
      user_teams: [github_team],
      repo_teams: [github_team],
    )
  end

  def hound_github_username
    ENV["HOUND_GITHUB_USERNAME"]
  end
end
