require_relative '../lib/inline_svg'

describe InlineSvg::FindsAssetPaths do
  it "returns fully qualified file paths from Sprockets" do
    sprockets = double('SprocketsDouble')

    expect(sprockets).to receive(:find_asset).with('some-file').
      and_return(double(pathname: Pathname('/full/path/to/some-file')))

    InlineSvg.configure do |config|
      config.asset_finder = sprockets
    end

    expect(InlineSvg::FindsAssetPaths.by_filename('some-file')).to eq Pathname('/full/path/to/some-file')
  end
end
