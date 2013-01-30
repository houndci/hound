require 'spec_helper'

describe BuildsController do
  describe '#create' do
    context 'with valid token' do
      it 'runs build' do
        user = create(
          :user,
          github_token: 'authtoken',
          github_username: 'salbertson'
        )

        pull_request = stub(github_login: user.github_username)
        PullRequest.stubs(new: pull_request)
        build_runner = mock(:run)
        BuildRunner.stubs(new: build_runner)
        api = mock
        GithubApi.stubs(new: api)

        post :create, { token: user.github_token, payload: pull_request_payload }

        expect(PullRequest).to have_received(:new).with(pull_request_payload)
        expect(GithubApi).to have_received(:new).with(user.github_token)
        expect(build_runner).to have_received(:run).with(pull_request, api)
      end
    end

    context 'without valid token' do
      it 'does not run build' do
        user = create(
          :user,
          github_token: 'authtoken',
          github_username: 'salbertson'
        )
        build_runner = mock
        BuildRunner.stubs(new: build_runner)

        post :create, { token: 'notauthorized', payload: pull_request_payload }

        expect(build_runner).to have_received(:run).never
      end
    end
  end

  def pull_request_payload
    File.read('spec/support/fixtures/github_pull_request_payload.json')
  end
end
