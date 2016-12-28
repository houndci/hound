require "rails_helper"

describe Linter::Credo do
  describe ".can_lint?" do
    context "given an .ex file" do
      it "returns true" do
        result = Linter::Credo.can_lint?("foo.ex")

        expect(result).to eq true
      end
    end

    context "given an .exs file" do
      it "returns true" do
        result = Linter::Credo.can_lint?("foo.exs")

        expect(result).to eq true
      end
    end

    context "given a non-markdown file" do
      it "returns false" do
        result = Linter::Credo.can_lint?("foo.txt")

        expect(result).to eq false
      end
    end
  end
end
