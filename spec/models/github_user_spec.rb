require 'spec_helper'

describe GithubUser, '#has_admin_access_through_team?' do
  context 'when team is admin team' do
    context 'when user belongs team' do
      it 'returns true' do
        token = 'abc123'
        api = GithubApi.new(token)
        user = GithubUser.new(api)
        team_id = 4567 # from fixture
        stub_user_teams_request(token)

        expect(user.has_admin_access_through_team?(team_id)).to be_true
      end
    end

    context 'when user does not belong to team' do
      it 'returns false' do
        token = 'abc123'
        api = GithubApi.new(token)
        user = GithubUser.new(api)
        team_id = 1111
        stub_user_teams_request(token)

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
        team_id = 1234 # from fixture
        stub_user_teams_request(token)

        expect(user.has_admin_access_through_team?(team_id)).to be_false
      end
    end
  end
end
