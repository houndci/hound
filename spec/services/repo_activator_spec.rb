require 'spec_helper'

describe RepoActivator do
  describe '#activate' do
    it 'activates repo' do
      user = build(:user)
      repo = create(:repo)
      hook = double(id: 'hookid')
      github = double(
        :github_api,
        create_pull_request_hook: hook
      ).as_null_object
      GithubApi.stub(:new).with(user.github_token).and_return(github)
      activator = RepoActivator.new

      activator.activate(repo, user)

      expect(repo.reload).to be_active
    end

    it 'creates GitHub hook' do
      user = build(:user)
      repo = create(:repo)
      hook = double(id: 'hookid')
      github = double(
        :github_api,
        create_pull_request_hook: hook
      ).as_null_object
      GithubApi.stub(new: github)
      activator = RepoActivator.new

      activator.activate(repo, user)

      expect(GithubApi).to have_received(:new).with(user.github_token)
      expect(github).to have_received(:create_pull_request_hook).with(
        repo.full_github_name,
        URI.join("http://#{ENV['HOST']}", 'builds').to_s
      )
    end

    it 'makes Hound a collaborator' do
      user = build(:user)
      repo = create(:repo)
      hook = double(id: 'hookid')
      github = double(
        :github_api,
        create_pull_request_hook: hook,
        add_hound_to_repo: true
      )
      GithubApi.stub(new: github)
      activator = RepoActivator.new

      activator.activate(repo, user)

      expect(GithubApi).to have_received(:new).with(user.github_token)
      expect(github).to have_received(:add_hound_to_repo)
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
