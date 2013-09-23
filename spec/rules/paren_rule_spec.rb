require 'fast_spec_helper'
require 'app/rules/rule'
require 'app/rules/paren_rule'

describe ParenRule, '#violated?' do
  context 'with proper syntax' do
    it 'is not violated' do
      example = 'test(:a, 23)'

      expect(example).not_to violate(ParenRule)
    end
  end

  context 'with whitespace after paren' do
    it 'is violated' do
      example = 'test( :a, 23)'

      expect(example).to violate(ParenRule)
    end
  end

  context 'with whitespace before closing paren' do
    it 'is violated' do
      example = 'test(:a, 23 )'

      expect(example).to violate(ParenRule)
    end
  end

  context 'with illegal whitespace around nested paren' do
    it 'is violated' do
      example = 'test = test_method(( 1..5), :date)'

      expect(example).to violate(ParenRule)
    end
  end

  context 'with line of ruby that has no paren' do
    it 'is not violated' do
      example = 'result = { a: user1, b: user2 }.each do |key, value|'

      expect(example).not_to violate(ParenRule)
    end
  end
end
