require 'spec_helper'

describe 'BuildJob', '#perform' do
  it 'runs the build' do
    build_runner = stub(:run)
    build_job = BuildJob.new(build_runner)

    build_job.perform

    expect(build_runner).to have_received(:run)
  end
end
