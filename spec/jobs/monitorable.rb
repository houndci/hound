require 'fast_spec_helper'
require 'app/jobs/monitorable'

describe Monitorable do
  class FakeJob
    include Monitorable
  end

  it 'captures exception using Raven' do
    Raven.stub(:capture_exception)
    job = FakeJob.new
    exception = double(:exception)

    job.error(job, exception)

    expect(Raven).to have_received(:capture_exception).with(exception)
  end
end
