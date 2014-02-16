require 'spec_helper'

describe BuildRunner, '#valid?' do
  let(:github_id) { '12345' }
  let(:payload_data) { { 'repository' => { 'id' => github_id } } }
  let(:build_runner) { BuildRunner.new(payload_data) }

  context 'with inactive repo' do
    it 'returns false' do
      create(:repo, github_id: github_id, active: false)

      expect(build_runner).not_to be_valid
    end
  end

  context 'with active repo' do
    context 'with synchronize action' do
      it 'returns true' do
        payload_data['action'] = 'synchronize'
        create(:active_repo, github_id: github_id)

        expect(build_runner).to be_valid
      end
    end

    context 'with opened action' do
      it 'returns true' do
        payload_data['action'] = 'opened'
        create(:active_repo, github_id: github_id)

        expect(build_runner).to be_valid
      end
    end

    context 'with closed action' do
      it 'returns false' do
        payload_data['action'] = 'closed'
        create(:active_repo, github_id: github_id)

        expect(build_runner).not_to be_valid
      end
    end
  end
end

describe BuildRunner, '#run' do
  let(:fixture_file) { 'spec/support/fixtures/pull_request_payload.json' }
  let(:payload_data) { JSON.parse(File.read(fixture_file)) }
  let(:pull_request) { stub_pull_request }

  before :each do
    create(:active_repo, github_id: payload_data['repository']['id'])
    line_violation = double(
      :line_violation,
      line_number: 123,
      messages: ['A message', 'Another message']
    )
    modified_line = double(:modified_line, line_number: 123, diff_position: 22)
    file_violation = double(
      :file_violation,
      filename: 'test.rb',
      line_violations: [line_violation],
      modified_lines: [modified_line]
    )
    style_checker = double(:style_checker, violations: [file_violation])
    StyleChecker.stub(new: style_checker)
    PullRequest.stub(new: pull_request)
  end

  context 'with violations' do
    it 'saves a build record' do
      build_runner = BuildRunner.new(payload_data)

      build_runner.run

      build = Build.last
      expect(build).to be_persisted
      expect(build.violations).to have_at_least(1).item
    end

    it 'creates a comment on GitHub' do
      build_runner = BuildRunner.new(payload_data)

      build_runner.run

      expect(pull_request).to have_received(:add_comment).with('test.rb', 22, anything)
    end
  end

  context 'with removed file' do
    it 'filters out removed files' do
      build_runner = BuildRunner.new(payload_data)
      pr_file1 = double(removed?: true, ruby?: true, filename: 'game.rb')
      pr_file2 = double(removed?: false, ruby?: true, filename: 'config.rb')
      pull_request = stub_pull_request(files: [pr_file1, pr_file2])

      build_runner.run

      expect(StyleChecker).to have_received(:new)
        .with([pr_file2], pull_request.config)
    end
  end

  context 'with non-ruby files' do
    it 'filters out non-ruby files' do
      build_runner = BuildRunner.new(payload_data)
      pr_file1 = double(removed?: false, ruby?: false, filename: 'path/app.js')
      pr_file2 = double(removed?: false, ruby?: true, filename: 'path/user.rb')
      pull_request = stub_pull_request(files: [pr_file1, pr_file2])

      build_runner.run

      expect(StyleChecker).to have_received(:new)
        .with([pr_file2], pull_request.config)
    end
  end

  context 'with ignored files' do
    it 'filters out ignored' do
      build_runner = BuildRunner.new(payload_data)
      schema = double(removed?: false, ruby?: true, filename: 'db/schema.rb')
      ruby_file = double(removed?: false, ruby?: true, filename: 'path/user.rb')
      pull_request = stub_pull_request(files: [schema, ruby_file])

      build_runner.run

      expect(StyleChecker).to have_received(:new)
        .with([ruby_file], pull_request.config)
    end
  end

  def stub_pull_request(options = {})
    default_options = {
      set_pending_status: nil,
      set_success_status: nil,
      set_failure_status: nil,
      config: nil,
      add_comment: nil,
      files: []
    }
    pull_request = double(:pull_request, default_options.merge(options))
    PullRequest.stub(new: pull_request)

    pull_request
  end
end
