require 'spec_helper'

describe 'BuildJob', '#perform' do
  describe 'when pull request is valid' do
    it 'runs the build' do
      pull_request = double(valid?: true)
      build_runner = double.as_null_object
      BuildRunner.stub(new: build_runner)
      build_job = BuildJob.new(pull_request)

      build_job.perform

      expect(build_runner).to have_received(:run)
      expect(BuildRunner).to have_received(:new).with(pull_request)
    end
  end

  describe 'when pull request is invalid' do
    it 'does not run the build' do
      pull_request = double(valid?: false)
      build_runner = double.as_null_object
      BuildRunner.stub(new: build_runner)
      build_job = BuildJob.new(pull_request)

      build_job.perform

      expect(build_runner).not_to have_received(:run)
    end
  end
end
