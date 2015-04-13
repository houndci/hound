require "rails_helper"

describe SmallBuildJob do
  it 'is retryable' do
    expect(SmallBuildJob.new).to be_a(Retryable)
  end

  it "queue_as medium" do
    expect(SmallBuildJob.new.queue_name).to eq("medium")
  end

  it 'is buildable' do
    expect(SmallBuildJob.new).to be_a(Buildable)
  end
end
