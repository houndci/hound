require 'test_helper'

describe Crack::XML do
  it "default to REXMLParser" do
    Crack::XML.parser.must_equal Crack::REXMLParser
  end

  describe "with a custom Parser" do
    class CustomParser
      def self.parse(xml)
        xml
      end
    end

    before do
      Crack::XML.parser = CustomParser
    end

    it "use the custom Parser" do
      Crack::XML.parse("<xml/>").must_equal "<xml/>"
    end

    after do
      Crack::XML.parser = nil
    end
  end
end
