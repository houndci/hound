require "spec_helper"

describe StyleGuideRetriever do
  describe "#retrieve" do
    context "coffeescript" do
      it "matches .coffee extensions and returns the coffeescript style guide" do
        file_one = "test.coffee.js"
        file_two = "test.js.coffee"
        file_three = "test.coffee"

        expect(style_guide_retriever.retrieve(file_one)).to eq StyleGuide::CoffeeScript
        expect(style_guide_retriever.retrieve(file_two)).to eq StyleGuide::CoffeeScript
        expect(style_guide_retriever.retrieve(file_three)).to eq StyleGuide::CoffeeScript
      end
    end

    context "javascript" do
      it "matches extensions ending in .js and returns the js guide" do
        file = "test.js"

        expect(style_guide_retriever.retrieve(file)).to eq StyleGuide::JavaScript
      end
    end

    context "ruby" do
      it "matches extensions ending in .rb and returns the ruby style guide" do
        file = "test.rb"

        expect(style_guide_retriever.retrieve(file)).to eq StyleGuide::Ruby
      end
    end

    context "unsupported" do
      it "returns an unsupported style guide" do
        file = "test.png"

        expect(style_guide_retriever.retrieve(file)).to eq StyleGuide::Unsupported
      end
    end

    def style_guide_retriever
      @style_guide_retriever ||= StyleGuideRetriever.new
    end
  end
end
