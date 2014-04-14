require 'spec_helper'

describe PullRequest, '#head_includes?' do
  context 'when HEAD commit includes line' do
    it 'returns true' do
      code = 'A line of code'
      line = Line.new(code)
      same_line = Line.new(code)
      modified_file = double(:modified_file, modified_lines: [line])
      ModifiedFile.stub(new: modified_file)
      commit_file = double(:commit_file)
      github = double(:github, commit_files: [commit_file])
      GithubApi.stub(new: github)
      payload = double(
        :payload,
        head_sha: 'headsha',
        full_repo_name: 'test/repo'
      )
      pull_request = PullRequest.new(payload, 'token')

      includes_line = pull_request.head_includes?(double(:line, content: code))

      expect(includes_line).to be_true
    end
  end

  context 'when HEAD commit does not include line' do
    it 'returns false' do
      line = Line.new('A line of code')
      different_line = Line.new('A different line of code')
      modified_file = double(:modified_file, modified_lines: [line])
      ModifiedFile.stub(new: modified_file)
      commit_file = double(:commit_file)
      github = double(:github, commit_files: [commit_file])
      GithubApi.stub(new: github)
      payload = double(
        :payload,
        head_sha: 'headsha',
        full_repo_name: 'test/repo'
      )
      pull_request = PullRequest.new(payload, 'token')

      includes_line = pull_request.head_includes?(different_line)

      expect(includes_line).to be_false
    end
  end
end

describe PullRequest, '#opened?' do
  context 'when payload action is opened' do
    it 'returns true' do
      payload = double(:payload, action: 'opened')
      pull_request = PullRequest.new(payload, 'token')

      expect(pull_request).to be_opened
    end
  end

  context 'when payload action is not opened' do
    it 'returns false' do
      payload = double(:payload, action: 'notopened')
      pull_request = PullRequest.new(payload, 'token')

      expect(pull_request).not_to be_opened
    end
  end
end

describe PullRequest, '#synchronize?' do
  context 'when payload action is synchronize' do
    it 'returns true' do
      payload = double(:payload, action: 'synchronize')
      pull_request = PullRequest.new(payload, 'token')

      expect(pull_request).to be_synchronize
    end
  end

  context 'when payload action is not synchronize' do
    it 'returns false' do
      payload = double(:payload, action: 'notsynchronize')
      pull_request = PullRequest.new(payload, 'token')

      expect(pull_request).not_to be_synchronize
    end
  end
end

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

describe PullRequest, '#config_hash' do
  context 'when config file is present' do
    it 'returns the contents of custom config' do
      contents = "StringLiterals:\n  Enabled: false"
      file_contents = double(:file_contents, content: Base64.encode64(contents))
      api = double(:github_api, file_contents: file_contents)
      pull_request = pull_request(api, file_contents)
      expected_config = {
        'StringLiterals' => {
          'Enabled' => false
        }
      }

      config = pull_request.config_hash

      expect(config).to eq(expected_config)
    end
  end

  context 'when config file is not present' do
    it 'returns nil' do
      api = double(:github_api)
      api.stub(:file_contents).and_raise(Octokit::NotFound)
      pull_request = pull_request(api)

      config_hash = pull_request.config_hash

      expect(config_hash).to eq({})
    end
  end
end

describe PullRequest, '#success_notification_enabled' do
  context 'when opened' do
    context 'with configuration' do
      context 'when enabled' do
        it 'returns true' do
          contents = "SuccessNotification:\n  Enabled: true"
          file_contents = double(:file_contents, content: Base64.encode64(contents))
          api = double(:github_api, file_contents: file_contents)
          pull_request = pull_request(api, file_contents)
          pull_request.stub(:opened?).and_return(true)

          enabled = pull_request.success_notification_enabled

          expect(enabled).to be_true
        end
      end
      context 'when disabled' do
        it 'returns false' do
          contents = "SuccessNotification:\n  Enabled: false"
          file_contents = double(:file_contents, content: Base64.encode64(contents))
          api = double(:github_api, file_contents: file_contents)
          pull_request = pull_request(api, file_contents)
          pull_request.stub(:opened?).and_return(true)

          enabled = pull_request.success_notification_enabled

          expect(enabled).to be_false
        end
      end
    end
    context 'without configuration' do
      it 'returns false' do
        api = double(:github_api)
        api.stub(:file_contents).and_raise(Octokit::NotFound)
        pull_request = pull_request(api)
        pull_request.stub(:opened?).and_return(true)

        enabled = pull_request.success_notification_enabled

        expect(enabled).to be_false
      end
    end
  end
  context 'when not opened' do
    it 'returns false' do
      contents = "SuccessNotification:\n  Enabled: true"
      file_contents = double(:file_contents, content: Base64.encode64(contents))
      api = double(:github_api, file_contents: file_contents)
      pull_request = pull_request(api, file_contents)
      pull_request.stub(:opened?).and_return(false)

      enabled = pull_request.success_notification_enabled

      expect(enabled).to be_false
    end
  end
end

def pull_request(api, file_contents = nil)
  payload = double(:payload, full_repo_name: 'org/repo', head_sha: 'abc123')
  GithubApi.stub(new: api)
  PullRequest.new(payload, 'gh-token')
end
