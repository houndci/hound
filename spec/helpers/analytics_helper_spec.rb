require "rails_helper"

describe AnalyticsHelper, '#analytics?' do
  it "is true when ENV['ANALYTICS'] is present" do
    ENV['ANALYTICS'] = 'anything'

    expect(analytics?).to be_truthy

    ENV['ANALYTICS'] = nil
  end

  it "is false when ENV['ANALYTICS'] is not present" do
    ENV['ANALYTICS'] = nil

    expect(analytics?).to be_falsy
  end
end
