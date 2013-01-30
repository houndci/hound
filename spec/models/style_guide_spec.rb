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

        expect(guide).to have(1).violations
      end
    end

    context 'with valid lines of code' do
      it 'has no violations' do
        rule = stub('violated?' => false)
        rules = [rule]
        guide = StyleGuide.new(rules)
        lines = ['line of code']

        guide.check(lines)

        expect(guide).to have(0).violations
      end
    end
  end
end
