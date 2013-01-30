require 'spec_helper'

feature 'Build' do
  scenario 'a successful build' do
    pull_request = PullRequest.new(payload)
    user = create(
      :user,
      github_token: 'authtoken',
      github_username: pull_request.github_login
    )
    stub_request(:any, /.*api.github.com.*/)
    stub_request(:get, pull_request.diff_url).
      to_return(
        :status => 200,
        :body => File.read('spec/support/fixtures/no_changes.diff'),
        :headers => {}
    )

    post builds_path, token: user.github_token, payload: payload

    expect_a_pending_status_request(pull_request, user)
    expect_a_diff_request(pull_request)
    expect_a_successful_status_request(pull_request, user)
  end

  scenario 'a failed build' do
    pull_request = PullRequest.new(payload)
    user = create(
      :user,
      github_token: 'authtoken',
      github_username: pull_request.github_login
    )
    stub_request(:any, /.*github.com.*/)
    stub_request(:get, pull_request.diff_url).
      to_return(
        :status => 200,
        :body => File.read('spec/support/fixtures/bad_style.diff'),
        :headers => {}
    )

    post builds_path, token: user.github_token, payload: payload

    expect_a_pending_status_request(pull_request, user)
    expect_a_diff_request(pull_request)
    expect_a_failure_status_request(pull_request, user)
  end

  def payload
    @payload ||= File.read('spec/support/fixtures/github_pull_request_payload.json')
  end

  def expect_a_pending_status_request(pull_request, user)
    expect(
      a_request(
        :post,
        "https://api.github.com/repos/#{pull_request.full_repo_name}/statuses/#{pull_request.sha}"
      ).with(
        :body => '{"description":"Hound is working...","state":"pending"}',
        :headers => { 'Authorization' => "token #{user.github_token}" }
      )
    ).to have_been_made
  end

  def expect_a_successful_status_request(pull_request, user)
    expect(
      a_request(
        :post,
        "https://api.github.com/repos/#{pull_request.full_repo_name}/statuses/#{pull_request.sha}"
      ).with(
        :body => '{"description":"Hound approves","state":"success"}',
        :headers => { 'Authorization' => "token #{user.github_token}" }
      )
    ).to have_been_made
  end

  def expect_a_failure_status_request(pull_request, user)
    expect(
      a_request(
        :post,
        "https://api.github.com/repos/#{pull_request.full_repo_name}/statuses/#{pull_request.sha}"
      ).with(
        :body => '{"description":"Hound does not approve","state":"failure"}',
        :headers => { 'Authorization' => "token #{user.github_token}" }
      )
    ).to have_been_made
  end

  def expect_a_diff_request(pull_request)
    expect(a_request(:get, pull_request.diff_url)).to have_been_made
  end
end
