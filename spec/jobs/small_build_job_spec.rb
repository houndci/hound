require 'fast_spec_helper'
require 'app/jobs/retryable'
require 'app/jobs/buildable'
require 'app/jobs/small_build_job'

describe SmallBuildJob do
  it 'is retryable' do
    expect(SmallBuildJob).to be_a(Retryable)
  end

  it 'is buildable' do
    expect(SmallBuildJob).to be_a(Buildable)
  end
end
