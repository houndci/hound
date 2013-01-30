require 'spec_helper'

describe BuildsController do
  describe '#create' do
    context 'from a GitHub IP address' do
      it 'creates GitHub status' do
        user = create(
          :user,
          github_token: 'authtoken',
          github_username: 'salbertson'
        )
        api = mock(:create_status)
        GithubApi.stubs(new: api)

        post :create, { token: user.github_token, payload: pull_request_payload }

        expect(GithubApi).to have_received(:new).with(user.github_token)
        expect(api).to have_received(:create_status).with(
          'salbertson/life',
          '498b81cd038f8a3ac02f035a8537b7ddcff38a81',
          'success',
          'Hound approves'
        )
      end
    end

    context 'from a non-GitHub IP address' do
      it 'does not create GitHub status' do
        user = create(
          :user,
          github_token: 'authtoken',
          github_username: 'salbertson'
        )
        api = mock
        GithubApi.stubs(new: api)

        post :create, { token: 'notauthorized', payload: pull_request_payload }

        expect(api).to have_received(:create_status).never
      end
    end
  end

  def pull_request_payload
    File.read('spec/support/fixtures/github_pull_request_payload.json')
  end
end
