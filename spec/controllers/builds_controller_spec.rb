require 'spec_helper'

describe BuildsController do
  describe '#create' do
    it 'creates GitHub status' do
      user = create(:user, github_token: 'authtoken', github_username: 'octocat')
      api = mock(:create_status)
      GithubApi.stubs(new: api)
      post_data = {
        pull_request: File.read('spec/support/fixtures/github_pull_request_payload.json')
      }

      post :create, post_data

      expect(GithubApi).to have_received(:new).with(user.github_token)
      expect(api).to have_received(:create_status).with(
        'octocat/Hello-World',
        '6dcb09b5b57875f334f61aebed695e2e4193db5e',
        'success',
        'Hound approves'
      )
    end
  end
end
