require 'fast_spec_helper'
require 'app/jobs/retryable'
require 'app/jobs/buildable'
require 'app/jobs/large_build_job'

describe LargeBuildJob do
  it 'is retryable' do
    expect(LargeBuildJob).to be_a(Retryable)
  end

  it 'is buildable' do
    expect(LargeBuildJob).to be_a(Buildable)
  end
end
