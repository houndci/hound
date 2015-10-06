require 'test_helper'

describe Crack::Util do
  describe "snake_case" do
    it "lowercases one word CamelCase" do
      Crack::Util.snake_case("Merb").must_equal "merb"
    end

    it "makes one underscore snake_case two word CamelCase" do
      Crack::Util.snake_case("MerbCore").must_equal "merb_core"
    end

    it "handles CamelCase with more than 2 words" do
      Crack::Util.snake_case("SoYouWantContributeToMerbCore").must_equal "so_you_want_contribute_to_merb_core"
    end

    it "handles CamelCase with more than 2 capital letter in a row" do
      Crack::Util.snake_case("CNN").must_equal "cnn"
      Crack::Util.snake_case("CNNNews").must_equal "cnn_news"
      Crack::Util.snake_case("HeadlineCNNNews").must_equal "headline_cnn_news"
    end

    it "does NOT change one word lowercase" do
      Crack::Util.snake_case("merb").must_equal "merb"
    end

    it "leaves snake_case as is" do
      Crack::Util.snake_case("merb_core").must_equal "merb_core"
    end
  end
end
