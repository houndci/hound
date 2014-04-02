require 'fast_spec_helper'
require 'app/models/line'

describe Line do
  describe '#==' do
    context 'when content is the same and line numbers are different' do
      it 'returns true' do
        line = Line.new('A line of code', 1)
        same_line = Line.new('A line of code', 2)

        expect(line).to eq same_line
      end
    end

    context 'when content is different' do
      it 'returns false' do
        line = Line.new('A line of code')
        different_line = Line.new('A different line of code')

        expect(line).not_to eq different_line
      end
    end
  end
end
