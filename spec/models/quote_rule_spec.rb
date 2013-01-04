require File.expand_path('../../support/matchers/violate_matcher', __FILE__)
require File.expand_path('../../../app/models/quote_rule.rb', __FILE__)

describe QuoteRule, '.violates?' do
  context 'with single quoted sting' do
    it 'is not violated for assignment' do
      expect(%(test = 'hello world')).not_to violate(QuoteRule)
    end

    it 'is not violated for array member' do
      expect(%([42, 'hello world'])).not_to violate(QuoteRule)
    end

    it 'is not violated for hash member' do
      expect(%({ number: 42, word: 'hello world' })).not_to violate(QuoteRule)
    end
  end

  context 'with double quoted sting' do
    it 'is violated for arbitrary string' do
      expect(%(it "hello #world {} #")).to violate(QuoteRule)
    end

    it 'is violated for assignment' do
      expect(%(test = "hello world")).to violate(QuoteRule)
    end

    it 'is violated for array member' do
      expect(%([42, "hello world"])).to violate(QuoteRule)
    end

    it 'is violated for hash member' do
      expect(%({ number: 42, word: "hello world" })).to violate(QuoteRule)
    end
  end

  context 'with double quoted interpolation sting' do
    it 'is not violated for assignment' do
      expect(%(test = "hello \#{world}")).not_to violate(QuoteRule)
    end

    it 'is not violated for array member' do
      expect(%([42, "hello \#{world}"])).not_to violate(QuoteRule)
    end

    it 'is not violated for hash member' do
      expect(%({ age: 42, word: "hello \#{world}" })).not_to violate(QuoteRule)
    end
  end
end
