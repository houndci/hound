require 'fast_spec_helper'
require 'lib/github_api'

describe GithubApi do
  describe '#get_repos' do
    it 'fetches repos from Github' do
      auth_token = 'authtoken'
      api = GithubApi.new(auth_token)
      stub_repos_request(auth_token)

      repos = api.get_repos

      expect(repos.size).to eq 1
    end
  end
end
