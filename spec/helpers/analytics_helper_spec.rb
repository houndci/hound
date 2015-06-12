require "rails_helper"

describe AnalyticsHelper, "#analytics?" do
  it 'is true when ENV["SEGMENT_KEY"] is present' do
    ENV["SEGMENT_KEY"] = "anything"

    expect(analytics?).to be_truthy

    ENV["SEGMENT_KEY"] = nil
  end

  it 'is false when ENV["SEGMENT_KEY"] is not present' do
    ENV["SEGMENT_KEY"] = nil

    expect(analytics?).to be_falsy
  end
end
