require 'fast_spec_helper'
require 'app/models/style_guide'

describe StyleGuide do
  describe '#check' do
    context 'with invalid lines of code' do
      it 'has violations' do
        files = ['trailing_whitespace = true  ']
        style_guide = StyleGuide.new

        style_guide.check(files)

        expect(style_guide).to have(1).violations
        expect(style_guide.violations).to eq([
          [1, files.first, 'Trailing whitespace detected.']
        ])
      end
    end

    context 'with valid lines of code' do
      it 'has no violations' do
        files = ['good line of code']
        style_guide = StyleGuide.new

        style_guide.check(files)

        expect(style_guide).to have(0).violations
      end
    end
  end
end
