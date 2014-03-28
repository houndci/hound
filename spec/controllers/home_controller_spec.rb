require 'spec_helper'

describe HomeController do
  describe '#index' do
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
end
