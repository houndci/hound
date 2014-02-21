require 'fast_spec_helper'
require 'app/jobs/monitorable'
require 'app/jobs/build_job'

describe BuildJob do
  it 'is monitored' do
    build_job = BuildJob.new(double)

    expect(build_job).to be_a Monitorable
  end
end

describe BuildJob, '#perform' do
  it 'runs the build' do
    build_runner = double(:build_runner, run: true)
    build_job = BuildJob.new(build_runner)

    build_job.perform

    expect(build_runner).to have_received(:run)
  end
end
