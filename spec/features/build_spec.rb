require 'spec_helper'

feature 'Build' do
  let(:payload) { File.read('spec/support/fixtures/pull_request_payload.json') }
  let(:parsed_payload) { JSON.parse(payload) }
  let(:repo_name) { parsed_payload['repository']['full_name'] }
  let(:sha) { parsed_payload['pull_request']['head']['sha'] }
  let(:number) { parsed_payload['number'] }

  scenario 'a successful build' do
    user = create(:user, github_username: 'salbertson', github_token: 'authtoken')
    stub_github_requests
    stub_pull_request_files_request(repo_name)

    post builds_path, payload: payload

    expect_a_pending_status_request(repo_name, sha, user.github_token)
    expect_a_pull_request_files_request(repo_name, number, user.github_token)
    expect_a_successful_status_request(repo_name, sha, user.github_token)
  end

  scenario 'a failed build' do
    user = create(:user, github_username: 'salbertson', github_token: 'authtoken')
    stub_github_requests
    stub_pull_request_files_request(repo_name, 'pull_request_files_with_errors.json')

    post builds_path, payload: payload

    expect_a_pending_status_request(repo_name, sha, user.github_token)
    expect_a_pull_request_files_request(repo_name, number, user.github_token)
    expect_a_failure_status_request(repo_name, sha, user.github_token)
  end

  def expect_a_pull_request_files_request(repo_name, number, token)
    expect(
      a_request(
        :get,
        "https://api.github.com/repos/#{repo_name}/pulls/#{number}/files"
      ).with(
        :headers => { 'Authorization' => "token #{token}" }
      )
    ).to have_been_made
  end

  def expect_a_pending_status_request(repo, sha, token)
    expect(
      a_request(
        :post,
        "https://api.github.com/repos/#{repo}/statuses/#{sha}"
      ).with(
        :body => '{"description":"Hound is working...","state":"pending"}',
        :headers => { 'Authorization' => "token #{token}" }
      )
    ).to have_been_made
  end

  def expect_a_successful_status_request(repo, sha, token)
    expect(
      a_request(
        :post,
        "https://api.github.com/repos/#{repo}/statuses/#{sha}"
      ).with(
        :body => '{"description":"Hound approves","state":"success"}',
        :headers => { 'Authorization' => "token #{token}" }
      )
    ).to have_been_made
  end

  def expect_a_failure_status_request(repo, sha, token)
    expect(
      a_request(
        :post,
        "https://api.github.com/repos/#{repo}/statuses/#{sha}"
      ).with(
        :body => '{"description":"Hound does not approve","state":"failure"}',
        :headers => { 'Authorization' => "token #{token}" }
      )
    ).to have_been_made
  end
end
