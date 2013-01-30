require 'spec_helper'

describe BuildsController do
  describe '#create' do
    context 'with valid token' do
      it 'checks pull request for style' do
        user = create(
          :user,
          github_token: 'authtoken',
          github_username: 'salbertson'
        )

        pull_request = stub(github_login: user.github_username)
        PullRequest.stubs(new: pull_request)
        checker = mock(:check)
        StyleChecker.stubs(new: checker)

        post :create, { token: user.github_token, payload: pull_request_payload }

        expect(PullRequest).to have_received(:new).with(pull_request_payload)
        expect(checker).to have_received(:check).with(pull_request, user.github_token)
      end
    end

    context 'without valid token' do
      it 'does not check pull request for style' do
        user = create(
          :user,
          github_token: 'authtoken',
          github_username: 'salbertson'
        )
        checker = mock
        StyleChecker.stubs(new: checker)

        post :create, { token: 'notauthorized', payload: pull_request_payload }

        expect(checker).to have_received(:check).never
      end
    end
  end

  def pull_request_payload
    File.read('spec/support/fixtures/github_pull_request_payload.json')
  end
end
