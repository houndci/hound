require 'fast_spec_helper'
require 'app/jobs/build_job'

describe BuildJob, '#perform' do
  it 'runs the build' do
    build_runner = double(:build_runner, run: true)
    build_job = BuildJob.new(build_runner)

    build_job.perform

    expect(build_runner).to have_received(:run)
  end
end

describe BuildJob, '#error' do
  it 'captures exception using the monitor' do
    monitor = double(capture_exception: nil)
    build_runner = double
    sync_job = BuildJob.new(build_runner, monitor)

    sync_job.error(double, StandardError)

    expect(monitor).to have_received(:capture_exception).with(StandardError)
  end
end
