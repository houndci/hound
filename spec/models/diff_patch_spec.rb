require 'fast_spec_helper'
require 'app/models/diff_patch'

describe DiffPatch do
  describe '#modified_line_numbers' do
    it 'returns modified line numbers' do
      diff = DiffPatch.new(example_diff)

      expect(diff.modified_line_numbers).to eq [14, 22, 54]
    end
  end

  def example_diff
    File.read('spec/support/fixtures/diff_patch.txt')
  end
end
