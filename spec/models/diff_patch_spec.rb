require 'fast_spec_helper'
require 'app/models/diff_patch'
require 'app/models/modified_line'

describe DiffPatch do
  describe '#modified_lines' do
    it 'returns modified lines with line numbers' do
      diff = DiffPatch.new(example_diff)

      expect(diff.modified_lines.map(&:line_number)).to eq [14, 22, 54]
    end

    it 'returns modified lines with diff positions' do
      diff = DiffPatch.new(example_diff)

      expect(diff.modified_lines.map(&:diff_position)).to eq [5, 13, 37]
    end
  end

  def example_diff
    File.read('spec/support/fixtures/diff_patch.txt')
  end
end
