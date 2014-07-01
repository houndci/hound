require "fast_spec_helper"

require "app/models/null_style_guide"

describe NullStyleGuide do
  it "doesn't report any violations" do
    style_guide = NullStyleGuide.new(double)

    expect(style_guide.violations(double)).to eq([])
  end
end
