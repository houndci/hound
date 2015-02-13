require "spec_helper"

describe AcceptOrgInvitationsJob do
  it "is retryable" do
    expect(AcceptOrgInvitationsJob).to be_a(Retryable)
  end

  it "accepts invitations" do
    github = double("GithubApi", accept_pending_invitations: nil)
    allow(GithubApi).to receive(:new).and_return(github)

    AcceptOrgInvitationsJob.perform

    expect(github).to have_received(:accept_pending_invitations)
  end

  it "retries when Resque::TermException is raised" do
    allow(GithubApi).to receive(:new).and_raise(Resque::TermException.new(1))
    allow(Resque).to receive(:enqueue)

    AcceptOrgInvitationsJob.perform

    expect(Resque).to have_received(:enqueue).
      with(AcceptOrgInvitationsJob)
  end
end
