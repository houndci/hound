require 'fast_spec_helper'
require 'app/models/style_guide'

describe StyleGuide do
  describe '#check' do
    context 'with invalid lines of code' do
      it 'has violations' do
        bad_code = "good line\n\tindentation = true "
        file1 = double(modified_line_numbers: [1], contents: 'whitespace = true ')
        file2 = double(modified_line_numbers: [2], contents: bad_code)
        style_guide = StyleGuide.new([file1, file2])

        style_guide.check

        expect(style_guide).to have(3).violations
        expect(style_guide.violations).to eq([
          [1, 'whitespace = true ', 'Trailing whitespace detected.'],
          [2, "\tindentation = true ", 'Tab detected.'],
          [2, "\tindentation = true ", 'Trailing whitespace detected.']
        ])
      end
    end

    context 'with valid lines of code' do
      it 'has no violations' do
        file = double(modified_line_numbers: [7], contents: 'def all_good')
        style_guide = StyleGuide.new([file])

        style_guide.check

        expect(style_guide).to have(0).violations
      end
    end
  end
end
