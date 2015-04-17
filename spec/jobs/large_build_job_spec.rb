require "rails_helper"

describe LargeBuildJob do
  it 'is retryable' do
    expect(LargeBuildJob.new).to be_a(Retryable)
  end

  it "queue_as low" do
    expect(LargeBuildJob.new.queue_name).to eq("low")
  end

  it 'is buildable' do
    expect(LargeBuildJob.new).to be_a(Buildable)
  end
end
