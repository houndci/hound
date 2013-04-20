require 'fast_spec_helper'
require 'rubocop'
require 'app/models/style_guide'

describe StyleGuide do
  describe '#check' do
    context 'with invalid lines of code' do
      it 'has violations' do
        guide = StyleGuide.new
        lines = ['blah = "string"']

        guide.check(lines)

        expect(guide).to have(1).violations
      end
    end

    context 'with valid lines of code' do
      it 'has no violations' do
        guide = StyleGuide.new
        lines = ["blah = 'string'"]

        guide.check(lines)

        expect(guide).to have(0).violations
      end
    end
  end
end
