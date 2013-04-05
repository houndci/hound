require 'spec_helper'

feature 'Build' do
  scenario 'a successful build' do
    commit = Commit.new(payload)
    user = create(
      :user,
      github_token: 'authtoken',
      github_username: 'salbertson'
    )
    stub_github_requests
    stub_compare_request(commit, user.github_token, 'compare_payload.json')

    post builds_path, token: user.github_token, payload: payload

    expect_a_pending_status_request(commit, user)
    expect_a_successful_status_request(commit, user)
  end

  scenario 'a failed build' do
    commit = Commit.new(payload)
    user = create(
      :user,
      github_token: 'authtoken',
      github_username: 'salbertson'
    )
    stub_github_requests
    stub_compare_request(commit, user.github_token, 'compare_with_errors.json')

    post builds_path, token: user.github_token, payload: payload

    expect_a_pending_status_request(commit, user)
    expect_a_failure_status_request(commit, user)
  end

  def payload
    @payload ||= File.read('spec/support/fixtures/commit_payload.json')
  end

  def expect_a_pending_status_request(commit, user)
    expect(
      a_request(
        :post,
        "https://api.github.com/repos/#{commit.full_repo_name}/statuses/#{commit.id}"
      ).with(
        :body => '{"description":"Hound is working...","state":"pending"}',
        :headers => { 'Authorization' => "token #{user.github_token}" }
      )
    ).to have_been_made
  end

  def expect_a_successful_status_request(commit, user)
    expect(
      a_request(
        :post,
        "https://api.github.com/repos/#{commit.full_repo_name}/statuses/#{commit.id}"
      ).with(
        :body => '{"description":"Hound approves","state":"success"}',
        :headers => { 'Authorization' => "token #{user.github_token}" }
      )
    ).to have_been_made
  end

  def expect_a_failure_status_request(commit, user)
    expect(
      a_request(
        :post,
        "https://api.github.com/repos/#{commit.full_repo_name}/statuses/#{commit.id}"
      ).with(
        :body => '{"description":"Hound does not approve","state":"failure"}',
        :headers => { 'Authorization' => "token #{user.github_token}" }
      )
    ).to have_been_made
  end
end
