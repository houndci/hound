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
  let(:pull_request) {
    double(
      :pull_request,
      set_pending_status: nil,
      set_success_status: nil,
      set_failure_status: nil,
      add_failure_comment: nil,
      files: []
    )
  }

  before :each do
    create(:active_repo, github_id: payload_data['repository']['id'])
    style_checker = double(:style_checker, violations: ['something failed'])
    StyleChecker.stub(new: style_checker)
    PullRequest.stub(new: pull_request)
  end

  context 'with violations' do
    it 'saves a build record' do
      build_runner = BuildRunner.new(payload_data)

      build_runner.run

      build = Build.last
      expect(build).to be_persisted
      expect(build.violations).to eq ['something failed']
    end

    it 'checks style guide and notifies GitHub of the failed build' do
      build_runner = BuildRunner.new(payload_data)

      build_runner.run

      expect(pull_request).to have_received(:set_pending_status)
      expect(pull_request).to have_received(:set_failure_status).
        with("http://#{ENV['HOST']}/builds/#{Build.last.uuid}")
    end

    it 'creates a comment on GitHub' do
      build_runner = BuildRunner.new(payload_data)

      build_runner.run

      expect(pull_request).to have_received(:add_failure_comment).
        with("http://#{ENV['HOST']}/builds/#{Build.last.uuid}")
    end
  end

  context 'without violations' do
    it 'checks style guide and notifies github of the passing build' do
      build_runner = BuildRunner.new(payload_data)
      style_checker = double(:style_checker, violations: [])
      StyleChecker.stub(new: style_checker)

      build_runner.run

      expect(pull_request).to have_received(:set_pending_status)
      expect(pull_request).to have_received(:set_success_status)
    end
  end

  context 'with removed file' do
    it 'filters out removed files' do
      build_runner = BuildRunner.new(payload_data)
      pull_request_file1 = double(
        :pr_file,
        removed?: true,
        ruby?: true,
        filename: 'game.rb'
      )
      pull_request_file2 = double(
        :pr_file,
        removed?: false,
        ruby?: true,
        filename: 'config.rb'
      )
      pull_request = double(
        :pull_request,
        set_pending_status: nil,
        set_success_status: nil,
        set_failure_status: nil,
        add_failure_comment: nil,
        files: [pull_request_file1, pull_request_file2]
      )
      PullRequest.stub(new: pull_request)

      build_runner.run

      expect(StyleChecker).to have_received(:new).with([pull_request_file2])
    end
  end

  context 'with non-ruby files' do
    it 'filters out non-ruby files' do
      build_runner = BuildRunner.new(payload_data)
      pull_request_file1 = double(
        :pr_file,
        removed?: false,
        ruby?: false,
        filename: 'app/assets/javascript/application.js'
      )
      pull_request_file2 = double(
        :pr_file,
        removed?: false,
        ruby?: true,
        filename: 'app/models/user.rb'
      )
      pull_request = double(
        :pull_request,
        set_pending_status: nil,
        set_success_status: nil,
        set_failure_status: nil,
        add_failure_comment: nil,
        files: [pull_request_file1, pull_request_file2]
      )
      PullRequest.stub(new: pull_request)

      build_runner.run

      expect(StyleChecker).to have_received(:new).with([pull_request_file2])
    end
  end

  context 'with ignored files' do
    it 'filters out ignored' do
      build_runner = BuildRunner.new(payload_data)
      ignored_file = double(
        :pr_file,
        removed?: false,
        ruby?: true,
        filename: 'db/schema.rb'
      )
      allowed_file = double(
        :pr_file,
        removed?: false,
        ruby?: true,
        filename: 'app/models/user.rb'
      )
      pull_request = double(
        :pull_request,
        set_pending_status: nil,
        set_success_status: nil,
        set_failure_status: nil,
        add_failure_comment: nil,
        files: [ignored_file, allowed_file]
      )
      PullRequest.stub(new: pull_request)

      build_runner.run

      expect(StyleChecker).to have_received(:new).with([allowed_file])
    end
  end
end
