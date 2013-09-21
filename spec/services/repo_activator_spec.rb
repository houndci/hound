require 'spec_helper'

describe RepoActivator do
  describe '#activate' do
    it 'activates repo' do
      repo = create(:repo)
      hook = stub(id: 1)
      api = stub(create_pull_request_hook: hook)
      activator = RepoActivator.new

      activator.activate(repo, api)

      expect(repo.reload).to be_active
    end

    it 'creates GitHub hook' do
      repo = create(:repo)
      hook = stub(id: 1)
      api = stub(create_pull_request_hook: hook)
      activator = RepoActivator.new

      activator.activate(repo, api)

      expect(api).to have_received(:create_pull_request_hook).with(
        repo.full_github_name,
        "http://#{ENV['HOST']}/builds?token=#{repo.user.github_token}"
      )
      expect(repo.reload.hook_id).to eq 1
    end
  end

  describe '#deactivate' do
    it 'deactivates repo' do
      api = stub
      api.stubs(remove_pull_request_hook: true)
      repo = Repo.new
      repo.stubs(full_github_name: 'jimtom/repo', hook_id: 1)
      activator = RepoActivator.new

      activator.deactivate(api, repo)

      expect(repo.active?).to be_false
    end

    it 'removes GitHub hook' do
      api = stub(:remove_pull_request_hook)
      repo = create(:repo, hook_id: 1)
      activator = RepoActivator.new

      activator.deactivate(api, repo)

      expect(api).to have_received(:remove_pull_request_hook)
      expect(repo.hook_id).to be_nil
    end

  end
end
