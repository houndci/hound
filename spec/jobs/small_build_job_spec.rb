require "rails_helper"

RSpec.describe SmallBuildJob do
  it "queues as medium" do
    expect(SmallBuildJob.queue).to eq(:medium)
  end

  it "is buildable" do
    expect(SmallBuildJob.new).to be_a(Buildable)
  end
end
