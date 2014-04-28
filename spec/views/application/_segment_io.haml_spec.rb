require 'spec_helper'

describe 'application/_segment_io.haml' do

  before do
    view.stub(signed_in?: false)
  end

  it 'loads the Segment.io Javascript library' do
    segment_load_line = "window.analytics.load"\
      "("#{ENV['SEGMENT_IO_WRITE_KEY']}");"

    render

    expect(rendered).to include(segment_load_line)
  end

  it 'records a pageview' do
    record_pageview_line = 'window.analytics.page();'

    render

    expect(rendered).to include(record_pageview_line)
  end

end
