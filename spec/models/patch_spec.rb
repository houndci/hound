# frozen_string_literal: true

require "spec_helper"
require 'app/models/patch'
require 'app/models/line'

describe Patch do
  describe "#changed_lines" do
    it 'returns lines that were modified' do
      patch_text = File.read('spec/support/fixtures/patch.diff')
      changed_lines = Patch.new(patch_text).changed_lines.each_value

      expect(changed_lines.size).to eq(3)
      expect(changed_lines.map(&:number)).to match_array [14, 22, 54]
      expect(changed_lines.map(&:patch_position)).to match_array [5, 13, 37]
    end

    context 'when body is nil' do
      it "returns no lines" do
        patch = Patch.new(nil)

        expect(patch.changed_lines.size).to eq(0)
      end
    end
  end
end
