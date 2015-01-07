require "spec_helper"

describe OrgInvitationJob do
  it "is retryable" do
    expect(OrgInvitationJob).to be_a(Retryable)
  end

  it "accepts invitations" do
    github = double("GithubApi", accept_pending_invitations: nil)
    allow(GithubApi).to receive(:new).and_return(github)

    OrgInvitationJob.perform_now

    expect(github).to have_received(:accept_pending_invitations)
  end

  it "retries when Resque::TermException is raised" do
    allow(GithubApi).to receive(:new).and_raise(Resque::TermException.new(1))
    allow(OrgInvitationJob.queue_adapter).to receive(:enqueue)

    job = OrgInvitationJob.perform_now

    expect(OrgInvitationJob.queue_adapter).to have_received(:enqueue).with(job)
  end
end
