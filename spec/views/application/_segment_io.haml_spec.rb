require 'spec_helper'

describe 'application/_segment_io.haml' do
  before do
    allow(view).to receive(:signed_in?).and_return(false)
  end

  it 'loads the Segment.io Javascript library' do
    segment_load_line =
      %Q(window.analytics.load("#{ENV["SEGMENT_IO_WRITE_KEY"]}");)

    render

    expect(rendered).to include(segment_load_line)
  end

  it 'records a pageview' do
    record_pageview_line = 'window.analytics.page("");'

    render

    expect(rendered).to include(record_pageview_line)
  end

  context "with page title and variation" do
    it "records pageview including page title and variation" do
      variation = "Happy Dog"
      page_title = "Landing Page"
      view.instance_variable_get("@view_flow").set(:variation, variation)
      view.instance_variable_get("@view_flow").set(:page_title, page_title)
      record_pageview_line = "window.analytics.page(\"#{page_title} > #{variation}\");"

      render

      expect(rendered).to include(record_pageview_line)
    end
  end
end
