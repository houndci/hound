require "rails_helper"

describe AcceptGitHubInvitationJob do
  it "queues as high" do
    expect(AcceptGitHubInvitationJob.queue).to eq(:high)
  end

  describe "#perform" do
    context "when Hound has access to the repo" do
      it "doesn't need to accept the invitation" do
        github = double(GitHubApi, repository?: true, accept_invitation: nil)
        allow(GitHubApi).to receive(:new).and_return(github)

        subject.perform("hound/test")

        expect(github).not_to have_received(:accept_invitation)
      end
    end

    context "when Hound doesn't have access to the repo" do
      it "accepts the invitation" do
        github = instance_double(
          GitHubApi,
          repository?: false,
          accept_invitation: nil,
        )
        allow(GitHubApi).to receive(:new).and_return(github)

        subject.perform("hound/test")

        expect(github).to have_received(:accept_invitation)
      end
    end
  end
end
