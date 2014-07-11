require "fast_spec_helper"

require "app/models/unknown_style_guide"

describe UnknownStyleGuide do
  it "doesn't report any violations" do
    style_guide = UnknownStyleGuide.new(double)

    expect(style_guide.violations(double)).to eq([])
  end
end
