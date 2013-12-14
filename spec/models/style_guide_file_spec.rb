require 'fast_spec_helper'
require 'rubocop'
require 'app/models/style_guide_file'

describe StyleGuideFile do
  describe '#violations' do
    context 'with invalid lines of code' do
      it 'returns violations' do
        contents = "good line\n\tindentation = true "

        file = StyleGuideFile.new('file.txt', contents, [1, 2])

        expect(file).to have(2).violations
        expect(file.violations).to eq([
          {
            line_number: 2,
            code: "\tindentation = true ",
            message: 'Tab detected.'
          },
          {
            line_number: 2,
            code: "\tindentation = true ",
            message: 'Trailing whitespace detected.'
          }
        ])
      end
    end
  end
end
