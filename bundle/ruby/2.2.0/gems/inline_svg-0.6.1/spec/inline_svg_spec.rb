require_relative '../lib/inline_svg'

class MyCustomTransform
  def self.create_with_value(value); end
  def transform(doc); end
end

class MyInvalidCustomTransformKlass
  def transform(doc); end
end

class MyInvalidCustomTransformInstance
  def self.create_with_value(value); end
end

describe InlineSvg do
  describe "configuration" do
    context "when a block is not given" do
      it "complains" do
        expect do
          InlineSvg.configure
        end.to raise_error(InlineSvg::Configuration::Invalid)
      end
    end

    context "asset finder" do
      it "allows an asset finder to be assigned" do
        sprockets = double('SomethingLikeSprockets', find_asset: 'some asset')
        InlineSvg.configure do |config|
          config.asset_finder = sprockets
        end

        expect(InlineSvg.configuration.asset_finder).to eq sprockets
      end

      it "complains when the provided asset finder does not implement #find_asset" do
        expect do
          InlineSvg.configure do |config|
            config.asset_finder = 'Not a real asset finder'
          end
        end.to raise_error(InlineSvg::Configuration::Invalid, /asset finder.*find_asset/i)
      end
    end

    context "configuring custom transformation" do
      it "allows a custom transformation to be added" do
        InlineSvg.configure do |config|
          config.add_custom_transformation(attribute: :my_transform, transform: MyCustomTransform)
        end

        expect(InlineSvg.configuration.custom_transformations).to eq({my_transform: MyCustomTransform})
      end

      it "rejects transformations that do not implement .create_with_value" do
        expect do
          InlineSvg.configure do |config|
            config.add_custom_transformation(attribute: :irrelevant, transform: MyInvalidCustomTransformKlass)
          end
        end.to raise_error(InlineSvg::Configuration::Invalid, /#{MyInvalidCustomTransformKlass} should implement the .create_with_value and #transform methods/)
      end

      it "rejects transformations that does not implement #transform" do
        expect do
          InlineSvg.configure do |config|
            config.add_custom_transformation(attribute: :irrelevant, transform: MyInvalidCustomTransformInstance)
          end
        end.to raise_error(InlineSvg::Configuration::Invalid, /#{MyInvalidCustomTransformInstance} should implement the .create_with_value and #transform methods/)
      end

      it "rejects transformations that are not classes" do
        expect do
          InlineSvg.configure do |config|
            config.add_custom_transformation(attribute: :irrelevant, transform: :not_a_class)
          end
        end.to raise_error(InlineSvg::Configuration::Invalid, /#{:not_a_class} should implement the .create_with_value and #transform methods/)
      end

    end
  end
end
