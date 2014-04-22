require 'spec_helper'

describe ReposController do
  describe '#index' do
    context 'when current user does not have an email address saved' do
      it 'pushes an email address job onto queue' do
        user = create(:user, email_address: nil)
        stub_sign_in(user)
        JobQueue.stub(:push)

        get :index, format: :json

        expect(JobQueue).to have_received(:push).with(
          EmailAddressJob,
          user.id,
          AuthenticationHelper::GITHUB_TOKEN
        )
      end
    end

    context 'when current user has an email address saved' do
      it 'does not push an email address job onto queue' do
        user = create(:user, email_address: 'test@example.com')
        stub_sign_in(user)
        JobQueue.stub(:push)

        get :index, format: :json

        expect(JobQueue).not_to have_received(:push)
      end
    end
  end
end
