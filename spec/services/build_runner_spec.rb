require 'spec_helper'

describe BuildRunner, '#run' do
  let(:pull_request) do
    double(
      :pull_request,
      set_pending_status: nil,
      set_success_status: nil,
      set_failure_status: nil,
      repo: create(:active_repo),
      files: []
    )
  end

  it 'does not check removed files' do
    removed_file = double(status: 'removed', filename: 'first.rb')
    added_file = double(status: 'added', filename: 'second.rb')
    pull_request = double(files: [removed_file, added_file]).as_null_object
    build_runner = BuildRunner.new(pull_request)
    style_checker = double.as_null_object
    StyleChecker.stub(new: style_checker)

    build_runner.run

    expect(StyleChecker).to have_received(:new).with([added_file])
  end

  it 'only checks Ruby files' do
    ruby_file = double(status: 'added', filename: 'ruby.rb')
    javascript_file = double(status: 'added', filename: 'javascript.js')
    pull_request = double(files: [ruby_file, javascript_file]).as_null_object
    build_runner = BuildRunner.new(pull_request)
    style_checker = double.as_null_object
    StyleChecker.stub(new: style_checker)

    build_runner.run

    expect(StyleChecker).to have_received(:new).with([ruby_file])
  end

  context 'with violations' do
    it 'saves a build record' do
      build_runner = BuildRunner.new(pull_request)
      style_checker = double(:style_checker, violations: ['something failed'])
      StyleChecker.stub(new: style_checker)

      build_runner.run

      build = Build.last
      expect(build).to be_persisted
      expect(build.violations).to eq ['something failed']
    end

    it 'checks style guide and notifies github of the failed build' do
      build_runner = BuildRunner.new(pull_request)
      style_checker = double(:style_checker, violations: ['something failed'])
      StyleChecker.stub(new: style_checker)

      build_runner.run

      expect(pull_request).to have_received(:set_pending_status)
      expect(pull_request).to have_received(:set_failure_status).
        with("http://#{ENV['HOST']}/builds/#{Build.last.id}")
    end
  end

  context 'without violations' do
    it 'checks style guide and notifies github of the passing build' do
      build_runner = BuildRunner.new(pull_request)

      build_runner.run

      expect(pull_request).to have_received(:set_pending_status)
      expect(pull_request).to have_received(:set_success_status)
    end
  end
end
