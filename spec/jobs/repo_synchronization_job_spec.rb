require 'spec_helper'

describe RepoSynchronizationJob, '#perform' do
  it 'syncs repos for a given user' do
    user = create(:user)
    sync_job = RepoSynchronizationJob.new(user.id)
    sync = double(start: nil)
    RepoSynchronization.stub(new: sync)

    sync_job.perform

    expect(RepoSynchronization).to have_received(:new).with(user)
    expect(sync).to have_received(:start)
  end
end

describe RepoSynchronizationJob, '#error' do
  it 'captures exception using the monitor' do
    monitor = double(capture_exception: nil)
    sync_job = RepoSynchronizationJob.new(123, monitor)

    sync_job.error(double, StandardError)

    expect(monitor).to have_received(:capture_exception).with(StandardError)
  end
end
