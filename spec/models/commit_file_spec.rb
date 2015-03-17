require "base64"

require "fast_spec_helper"
require "app/models/commit_file"
require "app/models/patch"
require "app/models/unchanged_line"

describe CommitFile do
  describe "#line_at" do
    context "with a changed line" do
      it "returns a line at the given line number" do
        line = double("Line", number: 1)
        patch = double("Patch", changed_lines: [line])
        allow(Patch).to receive(:new).and_return(patch)

        expect(commit_file.line_at(1)).to eq line
      end
    end

    context "without a changed line" do
      it "returns nil" do
        line = double("Line", number: 1)
        patch = double("Patch", changed_lines: [line])
        allow(Patch).to receive(:new).and_return(patch)

        expect(commit_file.line_at(2)).to be_an UnchangedLine
      end
    end
  end

  def commit_file(options = {})
    CommitFile.new("test.rb", "some content", "")
  end
end
