require 'spec_helper'

describe PullRequest, '#files' do
  let(:payload) {
    double(:payload, full_repo_name: 'org/repo', number: 4, head_sha: 'abc123')
  }

  it 'returns an array of modified files' do
    api = double(
      :github_api,
      pull_request_files: [
        double(filename: 'file1', status: 'modified', patch: 'patch 1'),
        double(filename: 'file2', status: 'modified', patch: 'patch 2')
      ]
    )
    GithubApi.stub(new: api)
    pull_request = PullRequest.new(payload, 'gh-token')

    files = pull_request.files

    expect(files).to have(2).items
    expect(files.first).to be_a ModifiedFile
    expect(api).to have_received(:pull_request_files).with('org/repo', 4)
  end
end

describe PullRequest, '#file_contents' do
  it 'calls api method with arguments' do
    payload = double(:payload, full_repo_name: 'org/repo', head_sha: 'abc123')
    pull_request = PullRequest.new(payload, 'gh-token')
    api = double(:github_api, file_contents: nil)
    GithubApi.stub(new: api)

    files = pull_request.file_contents('test.rb')

    expect(api).to have_received(:file_contents).
      with(payload.full_repo_name, 'test.rb', payload.head_sha)
  end
end
