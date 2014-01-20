require 'spec_helper'

feature 'Builds' do
  let(:payload) { File.read('spec/support/fixtures/pull_request_payload.json') }
  let(:parsed_payload) { JSON.parse(payload) }
  let(:repo_name) { parsed_payload['repository']['full_name'] }
  let(:repo_id) { parsed_payload['repository']['id'] }
  let(:pr_sha) { parsed_payload['pull_request']['head']['sha'] }
  let(:pr_number) { parsed_payload['number'] }

  scenario 'a successful build' do
    repo = create(:active_repo, github_id: repo_id, full_github_name: repo_name)
    stub_status_request(repo.full_github_name, pr_sha)
    stub_pull_request_files_request(repo.full_github_name, 2, repo.github_token)
    stub_contents_request(repo.full_github_name, pr_sha)

    post builds_path, payload: payload

    expect_a_pending_status_request(repo.full_github_name, pr_sha, repo.github_token)
    expect_a_pull_request_files_request(repo.full_github_name, pr_number, repo.github_token)
    expect_a_successful_status_request(repo.full_github_name, pr_sha, repo.github_token)

    visit build_path(Build.first.uuid)

    expect(page).not_to have_content 'Violations'
    expect(page).to have_content 'No violations'
  end

  scenario 'a failed build' do
    repo = create(:active_repo, github_id: repo_id, full_github_name: repo_name)
    stub_status_request(repo.full_github_name, pr_sha)
    stub_pull_request_files_request(repo.full_github_name, 2, repo.github_token)
    stub_contents_request(repo.full_github_name, pr_sha, 'contents_with_violations.json')

    post builds_path, payload: payload

    expect_a_pending_status_request(repo_name, pr_sha, repo.github_token)
    expect_a_pull_request_files_request(repo.full_github_name, pr_number, repo.github_token)
    expect_a_failure_status_request(repo.full_github_name, pr_sha, repo.github_token)

    visit build_path(Build.first.uuid)

    expect(page).to have_content 'Violations'
    expect(page).to have_content 'config/unicorn.rb'
    expect(page).to have_content '1 def some_method()'
    expect(page).to have_content 'Trailing whitespace detected'
    expect(page).to have_content 'Omit the parentheses in defs'
  end

  def expect_a_pull_request_files_request(repo_name, number, token)
    expect(
      a_request(
        :get,
        "https://api.github.com/repos/#{repo_name}/pulls/#{number}/files"
      ).with(
        headers: { 'Authorization' => "token #{token}" }
      )
    ).to have_been_made
  end

  def expect_a_pending_status_request(repo, sha, token)
    expect(
      a_request(
        :post,
        "https://api.github.com/repos/#{repo}/statuses/#{sha}"
      ).with(
        body: '{"description":"Hound is working...","state":"pending"}',
        headers: { 'Authorization' => "token #{token}" }
      )
    ).to have_been_made
  end

  def expect_a_successful_status_request(repo, sha, token)
    expect(
      a_request(
        :post,
        "https://api.github.com/repos/#{repo}/statuses/#{sha}"
      ).with(
        body: '{"description":"Hound approves","state":"success"}',
        headers: { 'Authorization' => "token #{token}" }
      )
    ).to have_been_made
  end

  def expect_a_failure_status_request(repo, sha, token)
    expect(
      a_request(
        :post,
        "https://api.github.com/repos/#{repo}/statuses/#{sha}"
      ).with(
        body: {
          description: 'Hound does not approve',
          target_url: "http://#{ENV['HOST']}#{build_path(Build.last.uuid)}",
          state: 'failure'
        }.to_json,
        headers: { 'Authorization' => "token #{token}" }
      )
    ).to have_been_made
  end
end
