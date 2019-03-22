require "rails_helper"

describe LargeBuildJob do
  it "queues as low" do
    expect(LargeBuildJob.queue).to eq(:low)
  end

  it 'is buildable' do
    expect(LargeBuildJob.new).to be_a(Buildable)
  end
end
