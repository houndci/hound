require 'fast_spec_helper'
require 'app/models/style_guide'

describe StyleGuide do
  describe '#check' do
    context 'with invalid lines of code' do
      it 'has violations' do
        rule = stub('violated?' => true)
        rules = [rule]
        guide = StyleGuide.new(rules)
        lines = ['line of code']

        guide.check(lines)

        expect(guide.violations).not_to be_empty
      end
    end

    context 'with valid lines of code' do
      it 'has no violations' do
        rule = stub('violated?' => false)
        rules = [rule]
        guide = StyleGuide.new(rules)
        lines = ['line of code']

        guide.check(lines)

        expect(guide.violations).to be_empty
      end
    end
  end
end
