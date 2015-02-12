require "spec_helper"

describe OrgInvitationJob do
  it "is retryable" do
    expect(OrgInvitationJob).to be_a(Retryable)
  end

  it "accepts invitations" do
    github_token = "something"
    github = double("GithubApi", accept_pending_invitations: nil)
    allow(GithubApi).to receive(:new).and_return(github)

    OrgInvitationJob.perform(github_token)

    expect(github).to have_received(:accept_pending_invitations)
  end

  it "retries when Resque::TermException is raised" do
    github_token = "something"
    allow(GithubApi).to receive(:new).and_raise(Resque::TermException.new(1))
    allow(Resque).to receive(:enqueue)

    OrgInvitationJob.perform(github_token)

    expect(Resque).to have_received(:enqueue).
      with(OrgInvitationJob)
  end
end
