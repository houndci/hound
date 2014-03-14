require 'spec_helper'

describe PullRequest, '#head_commit_files' do
  it 'returns modified files in the commit' do
    github_api = double(:github_api, commit_files: [double, double])
    GithubApi.stub(new: github_api)
    payload = double(
      :payload,
      full_repo_name: 'org/repo',
      number: 4,
      head_sha: 'abc123'
    )
    github_token = 'githubtoken'

    pull_request = PullRequest.new(payload, github_token)

    expect(pull_request.head_commit_files).to have(2).files
    expect(github_api).to have_received(:commit_files).with(
      payload.full_repo_name,
      payload.head_sha
    )
  end
end

describe PullRequest, '#file_contents' do
  it 'calls api method with arguments' do
    payload = double(:payload, full_repo_name: 'org/repo', head_sha: 'abc123')
    pull_request = PullRequest.new(payload, 'gh-token')
    api = double(:github_api, file_contents: double(content: ''))
    GithubApi.stub(new: api)

    files = pull_request.file_contents('test.rb')

    expect(api).to have_received(:file_contents).with(
      payload.full_repo_name,
      'test.rb',
      payload.head_sha
    )
  end
end

describe PullRequest, '#add_comment' do
  it 'posts a comment to GitHub for the Hound user' do
    payload = double(
      :payload,
      full_repo_name: 'org/repo',
      number: '123',
      head_sha: '1234abcd'
    )
    client = double(:github_client, add_comment: nil)
    GithubApi.stub(new: client)
    pull_request = PullRequest.new(payload, 'gh-token')

    pull_request.add_comment('test.rb', 123, 'A comment')

    expect(GithubApi).to have_received(:new).with(ENV['HOUND_GITHUB_TOKEN'])
    expect(client).to have_received(:add_comment).with(
      repo_name: payload.full_repo_name,
      pull_request_number: payload.number,
      comment: 'A comment',
      commit: payload.head_sha,
      filename: 'test.rb',
      line_number: 123
    )
  end
end

describe PullRequest, '#config' do
  context 'when config file is present' do
    it 'returns the contents of custom config' do
      file_contents = double(:file_contents, content: Base64.encode64('test'))
      api = double(:github_api, file_contents: file_contents)
      pull_request = pull_request(api, file_contents)

      config = pull_request.config

      expect(config).to eq('test')
    end
  end

  context 'when config file is not present' do
    it 'returns nil' do
      api = double(:github_api)
      api.stub(:file_contents).and_raise(Octokit::NotFound)
      pull_request = pull_request(api)

      config = pull_request.config

      expect(config).to be_nil
    end
  end
end

def pull_request(api, file_contents = nil)
  payload = double(:payload, full_repo_name: 'org/repo', head_sha: 'abc123')
  GithubApi.stub(new: api)
  PullRequest.new(payload, 'gh-token')
end
