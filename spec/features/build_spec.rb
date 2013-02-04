require 'spec_helper'

feature 'Build' do
  scenario 'a successful build' do
    pull_request = PullRequest.new(payload)
    user = create(
      :user,
      github_token: 'authtoken',
      github_username: pull_request.github_login
    )
    stub_pending_status_request(pull_request, user)
    stub_diff_request(pull_request, File.read('spec/support/fixtures/no_changes.diff'))
    stub_successful_status_request(pull_request, user)

    post builds_path, token: user.github_token, payload: payload
  end

  scenario 'a failed build' do
    pull_request = PullRequest.new(payload)
    user = create(
      :user,
      github_token: 'authtoken',
      github_username: pull_request.github_login
    )
    stub_pending_status_request(pull_request, user)
    stub_diff_request(pull_request, File.read('spec/support/fixtures/bad_style.diff'))
    stub_failure_status_request(pull_request, user)

    post builds_path, token: user.github_token, payload: payload
  end

  def payload
    @payload ||= File.read('spec/support/fixtures/github_pull_request_payload.json')
  end

  def stub_pending_status_request(pull_request, user)
    stub_request(
      :post,
      "https://api.github.com/repos/#{pull_request.full_repo_name}/statuses/#{pull_request.sha}"
    ).with(
      :body => '{"description":"Hound is working...","state":"pending"}',
      :headers => { 'Authorization' => "token #{user.github_token}" }
    ).to_return(:status => 200, :body => '', :headers => {})
  end

  def stub_successful_status_request(pull_request, user)
    stub_request(
      :post,
      "https://api.github.com/repos/#{pull_request.full_repo_name}/statuses/#{pull_request.sha}"
    ).with(
      :body => '{"description":"Hound approves","state":"success"}',
      :headers => { 'Authorization' => "token #{user.github_token}" }
    ).to_return(:status => 200, :body => '', :headers => {})
  end

  def stub_failure_status_request(pull_request, user)
    stub_request(
      :post,
      "https://api.github.com/repos/#{pull_request.full_repo_name}/statuses/#{pull_request.sha}"
    ).with(
      :body => '{"description":"Hound does not approve","state":"failure"}',
      :headers => { 'Authorization' => "token #{user.github_token}" }
    ).to_return(:status => 200, :body => '', :headers => {})
  end

  def stub_diff_request(pull_request, diff)
    stub_request(:get, pull_request.diff_url).
      to_return(:status => 200, :body => diff, :headers => {})
  end
end
