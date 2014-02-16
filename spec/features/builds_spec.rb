require 'spec_helper'

feature 'Builds' do
  let(:payload) { File.read('spec/support/fixtures/pull_request_payload.json') }
  let(:zen_payload) { File.read('spec/support/fixtures/zen_payload.json') }
  let(:parsed_payload) { JSON.parse(payload) }
  let(:repo_name) { parsed_payload['repository']['full_name'] }
  let(:repo_id) { parsed_payload['repository']['id'] }
  let(:pr_sha) { parsed_payload['pull_request']['head']['sha'] }
  let(:pr_number) { parsed_payload['number'] }

  scenario 'a successful signup' do
    response = post builds_path, payload: zen_payload
    expect(response).to eq 200
  end

  scenario 'a successful build with custom config' do
    repo = create(:active_repo, github_id: repo_id, full_github_name: repo_name)
    stub_pull_request_files_request(repo.full_github_name, 2, repo.github_token)
    stub_contents_request(repo_name: repo.full_github_name, sha: pr_sha)
    stub_contents_request(
      repo_name: repo.full_github_name,
      sha: pr_sha,
      file: '.hound.yml',
      fixture: 'config_contents.json'
    )

    post builds_path, payload: payload

    expect_a_pull_request_files_request(repo.full_github_name, pr_number, repo.github_token)

    visit build_path(Build.first.uuid)

    expect(page).not_to have_content 'Violations'
    expect(page).to have_content 'No violations'
  end

  scenario 'a failed build' do
    repo = create(:active_repo, github_id: repo_id, full_github_name: repo_name)
    stub_request(:post, 'https://api.github.com/repos/salbertson/life/pulls/2/comments')
    stub_pull_request_files_request(repo.full_github_name, 2, repo.github_token)
    stub_contents_request(
      repo_name: repo.full_github_name,
      sha: pr_sha,
      fixture: 'contents_with_violations.json'
    )
    stub_contents_request(
      repo_name: repo.full_github_name,
      sha: pr_sha,
      file: '.hound.yml',
      fixture: 'config_contents.json'
    )

    post builds_path, payload: payload

    expect_a_pull_request_files_request(repo.full_github_name, pr_number, repo.github_token)
    expect_a_comment_request(repo.full_github_name, pr_number)

    build = Build.first
    visit build_path(build.uuid)

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

  def expect_a_comment_request(repo_name, pull_request_number)
    url = "https://api.github.com/repos/#{repo_name}/pulls/#{pull_request_number}/comments"

    expect(
      a_request(:post, url)
    ).to have_been_made
  end
end
