require 'spec_helper'

describe RepoActivator do
  describe '#activate' do
    it 'activates repo' do
      stub_github_api
      repo = create(:repo)
      create(:membership, repo: repo)
      activator = RepoActivator.new

      activator.activate(repo)

      expect(repo.reload).to be_active
    end

    it 'creates GitHub hook' do
      github_api = stub_github_api
      repo = create(:repo)
      create(:membership, repo: repo)
      activator = RepoActivator.new

      activator.activate(repo)

      expect(GithubApi).to have_received(:new).with(repo.github_token)
      expect(github_api).to have_received(:create_pull_request_hook).with(
        repo.full_github_name,
        "http://#{ENV['HOST']}/builds"
      )
      expect(repo.reload.hook_id).to eq 1
    end
  end

  describe '#deactivate' do
    it 'deactivates repo' do
      stub_github_api
      repo = create(:repo)
      create(:membership, repo: repo)
      activator = RepoActivator.new

      activator.deactivate(repo)

      expect(repo.active?).to be_false
    end

    it 'removes GitHub hook' do
      github_api = stub_github_api
      repo = create(:repo)
      create(:membership, repo: repo)
      activator = RepoActivator.new

      activator.deactivate(repo)

      expect(github_api).to have_received(:remove_pull_request_hook)
      expect(repo.hook_id).to be_nil
    end
  end

  def stub_github_api
    hook = double(:hook, id: 1)
    api = double(
      :github_api,
      create_pull_request_hook: hook,
      remove_pull_request_hook: nil
    )
    GithubApi.stub(new: api)
    api
  end
end
