require 'fast_spec_helper'
require 'app/jobs/monitorable'
require 'app/jobs/build_job'
require 'octokit'

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

describe BuildJob, '#error' do
  context 'with Octokit::NotFound exception' do
    it 'sets job to failed' do
      build_runner = double(:build_runner, run: true)
      build_job = BuildJob.new(build_runner)
      job = double(fail!: true, id: 1)

      build_job.error(job, Octokit::NotFound.new)

      expect(job).to have_received(:fail!)
    end
  end

  context 'with Octokit::Unauthorized exception' do
    it 'sets job to failed' do
      build_runner = double(:build_runner, run: true)
      build_job = BuildJob.new(build_runner)
      job = double(fail!: true, id: 1)

      build_job.error(job, Octokit::Unauthorized.new)

      expect(job).to have_received(:fail!)
    end
  end

  context 'with another exception' do
    it 'does not update failed_at' do
      Raven.stub(:capture_exception)
      build_runner = double(:build_runner, run: true)
      job = double(fail!: true, id: 1)
      exception = double(:exception)
      build_job = BuildJob.new(build_runner)

      build_job.error(job, exception)

      expect(Raven).to have_received(:capture_exception).with(
        exception,
        extra: { job_id: job.id }
      )
      expect(job).not_to have_received(:fail!)
    end
  end
end
