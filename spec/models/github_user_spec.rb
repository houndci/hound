require 'spec_helper'

describe GithubUser, '#has_admin_access_through_team?' do
  context 'when team is admin team' do
    context 'when user belongs team' do
      it 'returns true' do
        team_id = 4567 # from fixture
        api = GithubApi.new
        user = GithubUser.new(api)
        teams = [double(permission: 'admin', id: team_id)]
        allow(api).to receive(:user_teams).and_return(teams)

        expect(user).to have_admin_access_through_team(team_id)
      end
    end

    context 'when user does not belong to team' do
      it 'returns false' do
        api = GithubApi.new
        user = GithubUser.new(api)
        team_id = 1111
        teams = [double(permission: 'admin', id: 4567)]
        allow(api).to receive(:user_teams).and_return(teams)

        expect(user).not_to have_admin_access_through_team(team_id)
      end
    end
  end

  context 'when team is not admin team' do
    context 'when user belongs to team' do
      it 'returns false' do
        api = GithubApi.new
        user = GithubUser.new(api)
        team_id = 4567
        teams = [double(permission: "push", id: 4567)]
        allow(api).to receive(:user_teams).and_return(teams)

        expect(user).not_to have_admin_access_through_team(team_id)
      end
    end
  end
end
