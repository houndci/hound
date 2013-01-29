require 'spec_helper'

describe BuildsController do
  describe '#create' do
    context 'from a GitHub IP address' do
      it 'creates GitHub status' do
        user = create(
          :user,
          github_token: 'authtoken',
          github_username: 'octocat'
        )
        api = mock(:create_status)
        GithubApi.stubs(new: api)
        request.env['HTTP_REFERER'] = BuildsController::GITHUB_IPS.first

        post :create, { pull_request: pull_request_payload }

        expect(GithubApi).to have_received(:new).with(user.github_token)
        expect(api).to have_received(:create_status).with(
          'octocat/Hello-World',
          '6dcb09b5b57875f334f61aebed695e2e4193db5e',
          'success',
          'Hound approves'
        )
      end
    end

    context 'from a non-GitHub IP address' do
      it 'does not create GitHub status' do
        api = mock
        GithubApi.stubs(new: api)
        request.env['HTTP_REFERER'] = '123.45.678.910'

        post :create, { pull_request: pull_request_payload }

        expect(api).to have_received(:create_status).never
      end
    end
  end

  def pull_request_payload
    File.read('spec/support/fixtures/github_pull_request_payload.json')
  end
end
