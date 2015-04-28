require "base64"

require "spec_helper"
require "app/models/pull_request_file"
require "app/models/patch"
require "app/models/unchanged_line"

describe PullRequestFile do
  describe "#line_at" do
    context "with a changed line" do
      it "returns a line at the given line number" do
        line = double("Line", number: 1)
        patch = double("Patch", changed_lines: [line])
        allow(Patch).to receive(:new).and_return(patch)

        expect(pull_request_file.line_at(1)).to eq line
      end
    end

    context "without a changed line" do
      it "returns nil" do
        line = double("Line", number: 1)
        patch = double("Patch", changed_lines: [line])
        allow(Patch).to receive(:new).and_return(patch)

        expect(pull_request_file.line_at(2)).to be_an UnchangedLine
      end
    end
  end

  describe "#content" do
    context "when value is callable" do
      it "returns the return value of the callable object" do
        file = PullRequestFile.new("test.rb", -> { :sentinel }, "")

        expect(file.content).to eq :sentinel
      end
    end

    context "when value is not callable" do
      it "returns the value" do
        file = PullRequestFile.new("test.rb", :sentinel, "")

        expect(file.content).to eq :sentinel
      end
    end
  end

  def pull_request_file
    PullRequestFile.new("test.rb", "some content", "")
  end
end
