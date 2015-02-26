require "fast_spec_helper"
require "app/models/patch"
require "app/models/line"
require "app/models/unchanged_line"

describe Patch do
  describe ".find_line" do
    context "given a valid patch" do
      it "finds the matching line" do
        patch_body = File.read("spec/support/fixtures/patch.diff")

        line = Patch.find_line(patch_body, 14)

        expect(line.number).to eq 14
      end
    end

    context "given invalid patch" do
      it "returns `UnchangedLine`" do
        line = Patch.find_line("", 9999)

        expect(line).to be_a UnchangedLine
        expect(line.number).to eq 0
        expect(line.patch_position).to eq -1
      end
    end
  end

  describe "#changed_lines" do
    it "returns lines that were modified" do
      patch_body = File.read("spec/support/fixtures/patch.diff")
      patch = Patch.new(patch_body)

      expect(patch.changed_lines.size).to eq(3)
      expect(patch.changed_lines.map(&:number)).to eq [14, 22, 54]
      expect(patch.changed_lines.map(&:patch_position)).to eq [5, 13, 37]
    end

    context "when body is nil" do
      it "returns no lines" do
        patch = Patch.new(nil)

        expect(patch.changed_lines.size).to eq(0)
      end
    end
  end
end
