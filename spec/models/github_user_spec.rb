require 'spec_helper'

describe GithubUser, '#has_admin_access_through_team?' do
  context 'when team is admin team' do
    context 'when user belongs team' do
      it 'returns true' do
        token = 'abc123'
        team_id = 4567 # from fixture
        api = GithubApi.new(token)
        user = GithubUser.new(api)
        teams = [double(permission: 'admin', id: team_id)]
        api.stub(user_teams: teams)

        expect(user.has_admin_access_through_team?(team_id)).to be_true
      end
    end

    context 'when user does not belong to team' do
      it 'returns false' do
        token = 'abc123'
        api = GithubApi.new(token)
        user = GithubUser.new(api)
        team_id = 1111
        teams = [double(permission: 'admin', id: 4567)]
        api.stub(user_teams: teams)

        expect(user.has_admin_access_through_team?(team_id)).to be_false
      end
    end
  end

  context 'when team is not admin team' do
    context 'when user belongs to team' do
      it 'returns false' do
        token = 'abc123'
        api = GithubApi.new(token)
        user = GithubUser.new(api)
        team_id = 4567
        teams = [
          double(permission: 'pull', id: 4567)
        ]
        api.stub(user_teams: teams)

        expect(user.has_admin_access_through_team?(team_id)).to be_false
      end
    end
  end
end
