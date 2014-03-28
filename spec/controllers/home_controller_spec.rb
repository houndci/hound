require 'spec_helper'

describe HomeController do
  describe '#index' do
    context 'when user has no repos' do
      it 'enqueues a repo sync job' do
        user = create(:user)
        sync_job = double()
        RepoSynchronizationJob.stub(new: sync_job)
        Delayed::Job.stub(enqueue: true)
        stub_sign_in(user)

        get :index

        expect(RepoSynchronizationJob).to have_received(:new).with(user.id)
        expect(Delayed::Job).to have_received(:enqueue).with(sync_job)
      end
    end

    context 'when user has repos' do
      it 'does not enqueue a repo sync job' do
        membership = create(:membership)
        sync_job = double()
        RepoSynchronizationJob.stub(new: sync_job)
        Delayed::Job.stub(enqueue: true)
        stub_sign_in(membership.user)

        get :index

        expect(RepoSynchronizationJob).not_to have_received(:new).with(membership.user.id)
        expect(Delayed::Job).not_to have_received(:enqueue).with(sync_job)
      end
    end
  end
end
