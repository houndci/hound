require 'fast_spec_helper'
require 'app/models/rule'
require 'app/models/parenthesis_rule'

describe ParenthesisRule, '#violated?' do
  context 'with proper syntax' do
    it 'is not violated' do
      example = 'test(:a, 23)'

      expect(example).not_to violate(ParenthesisRule)
    end
  end

  context 'with whitespace after parenthesis' do
    it 'is violated' do
      example = 'test( :a, 23)'

      expect(example).to violate(ParenthesisRule)
    end
  end

  context 'with whitespace before closing parenthesis' do
    it 'is violated' do
      example = 'test(:a, 23 )'

      expect(example).to violate(ParenthesisRule)
    end
  end

  context 'with illegal whitespace around nested parenthesis' do
    it 'is violated' do
      example = 'test = test_method(( 1..5), :date)'

      expect(example).to violate(ParenthesisRule)
    end
  end

  context 'with line of ruby that has no parenthesis' do
    it 'is not violated' do
      example = 'result = { a: user1, b: user2 }.each do |key, value|'

      expect(example).not_to violate(ParenthesisRule)
    end
  end
end
