require "rails_helper"

describe "application/_analytics.haml" do
  before do
    allow(view).to receive(:signed_in?).and_return(false)
    user = double("user").as_null_object
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:identify_hash).and_return({})
    allow(view).to receive(:intercom_hash).and_return({})
  end

  it "loads the Segment JavaScript library" do
    segment_load_line =
      %(window.analytics.load("#{ENV['SEGMENT_KEY']}");)

    render

    expect(rendered).to include(segment_load_line)
  end

  it "records a pageview" do
    record_pageview_line = "window.analytics.page"

    render

    expect(rendered).to include(record_pageview_line)
  end
end
