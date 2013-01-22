require 'fast_spec_helper'
require 'app/models/rule'
require 'app/models/method_paren_rule'

describe MethodParenRule, '#violated?' do
  context 'a method with parens' do
    it 'is not violated for a method with a single argument' do
      expect(%{def doctor(who)}).not_to violate(MethodParenRule)
    end

    it 'is not violated for a method with multiple arguments' do
      expect(%{def who?(are_you, who_who)}).not_to violate(MethodParenRule)
    end

    it 'is violated for a method with parens but no arguments' do
      expect(%{def nonsense()}).to violate(MethodParenRule)
    end
  end

  context 'a method without parens' do
    it 'is not violated for a method with no arguments' do
      expect(%(def chuck_norris)).not_to violate(MethodParenRule)
    end

    it 'is violated for a method with an argument' do
      expect(%(def valid ruby)).to violate(MethodParenRule)
    end
  end

  context 'not a method definition' do
    it 'is not violated for ranges' do
      expect(%{(1..10)}).not_to violate(MethodParenRule)
    end

    it 'is not violated for method calls' do
      expect(%{pass(message)}).not_to violate(MethodParenRule)
    end

    it 'is not violated for an unassuming line of ruby' do
      expect(%(x == y)).not_to violate(MethodParenRule)
    end
  end
end
