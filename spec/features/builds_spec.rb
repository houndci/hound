require 'spec_helper'

feature 'Builds' do
  let(:payload) do
    File.read('spec/support/fixtures/pull_request_opened_event.json')
  end
  let(:parsed_payload) { JSON.parse(payload) }
  let(:repo_name) { parsed_payload['repository']['full_name'] }
  let(:repo_id) { parsed_payload['repository']['id'] }
  let(:pr_sha) { parsed_payload['pull_request']['head']['sha'] }
  let(:pr_number) { parsed_payload['number'] }

  context 'with payload nesting' do
    scenario 'a successful build with custom config' do
      create(:repo, github_id: repo_id, full_github_name: repo_name)
      stub_github_requests_with_no_violations
      comment_request = stub_simple_comment_request

      page.driver.post builds_path, payload: payload

      expect(comment_request).not_to have_been_requested
    end
  end

  context 'without payload nesting' do
    scenario 'a successful build with custom config' do
      create(:repo, github_id: repo_id, full_github_name: repo_name)
      stub_github_requests_with_no_violations
      comment_request = stub_simple_comment_request

      page.driver.post builds_path, payload

      expect(comment_request).not_to have_been_requested
    end
  end

  scenario 'a failed build' do
    create(:repo, :active, github_id: repo_id, full_github_name: repo_name)
    stub_github_requests_with_violations
    stub_commit_request(repo_name, pr_sha)
    stub_pull_request_comments_request(repo_name, pr_number)
    comment_request = stub_simple_comment_request
    stub_status_requests(repo_name, pr_sha)

    page.driver.post builds_path, payload: payload

    expect(comment_request).to have_been_requested
  end

  def stub_github_requests_with_no_violations
    stub_pull_request_files_request(repo_name, pr_number)
    stub_contents_request(
      repo_name: repo_name,
      sha: pr_sha,
      file: 'file1.rb',
      fixture: 'contents.json'
    )
    stub_contents_request(
      repo_name: repo_name,
      sha: pr_sha,
      file: '.hound.yml',
      fixture: 'config_contents.json'
    )
  end

  def stub_github_requests_with_violations
    stub_pull_request_files_request(repo_name, pr_number)
    stub_contents_request(
      repo_name: repo_name,
      sha: pr_sha,
      file: '.hound.yml',
      fixture: 'config_contents.json'
    )
    stub_contents_request(
      repo_name: repo_name,
      sha: pr_sha,
      fixture: 'contents_with_violations.json'
    )
  end

  def stub_simple_comment_request
    stub_request(
      :post,
      "https://api.github.com/repos/#{repo_name}/pulls/#{pr_number}/comments"
    )
  end
end
