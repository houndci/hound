require 'fast_spec_helper'
require 'app/models/style_guide'

describe StyleGuide, '#violations' do
  context 'when some files have violations' do
    it 'returns only the files with violations' do
      file1 = double(filename: 'file1', violations: ['violation 1', 'violation 2'])
      file2 = double(filename: 'file2', violations: [])
      file3 = double(filename: 'file3', violations: ['violation 4'])

      style_guide = StyleGuide.new([file1, file2, file3])

      expect(style_guide.violations).to eq([
        { filename: 'file1', violations: ['violation 1', 'violation 2'] },
        { filename: 'file3', violations: ['violation 4'] }
      ])
    end
  end
end
