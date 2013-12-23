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
