require 'fast_spec_helper'
require 'app/jobs/monitorable'

describe Monitorable do
  class FakeJob
    include Monitorable
  end

  it 'captures exception with context using Raven' do
    Raven.stub(:capture_exception)
    job = FakeJob.new
    exception = double(:exception)
    job_param = double(id: 123)

    job.error(job_param, exception)

    expect(Raven).to have_received(:capture_exception).with(
      exception,
      extra: { job_id: job_param.id }
    )
  end
end
