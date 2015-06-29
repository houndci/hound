require "spec_helper"
require 'app/models/patch'
require 'app/models/line'

describe Patch do
  describe "#changed_lines" do
    it 'returns lines that were modified' do
      patch_text = File.read('spec/support/fixtures/patch.diff')
      patch = Patch.new(patch_text)

      expect(patch.changed_lines.size).to eq(3)
      expect(patch.changed_lines.map(&:number)).to eq [14, 22, 54]
      expect(patch.changed_lines.map(&:patch_position)).to eq [5, 13, 37]
    end

    context 'when body is nil' do
      it "returns no lines" do
        patch = Patch.new(nil)

        expect(patch.changed_lines.size).to eq(0)
      end
    end
  end
end
