require 'spec_helper'

describe RepoSynchronizationJob do
  it 'is monitored' do
    build_job = RepoSynchronizationJob.new(double)

    expect(build_job).to be_a Monitorable
  end
end

describe RepoSynchronizationJob, '#perform' do
  it 'syncs repos for a given user' do
    user = create(:user)
    github_token = 'githubtoken'
    sync_job = RepoSynchronizationJob.new(user.id, github_token)
    sync = double(start: nil)
    RepoSynchronization.stub(new: sync)

    sync_job.perform

    expect(RepoSynchronization).to have_received(:new).with(user, github_token)
    expect(sync).to have_received(:start)
  end
end
