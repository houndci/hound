require 'fast_spec_helper'
require 'app/models/rule'
require 'app/models/method_parens_rule'

describe MethodParensRule, '#violated?' do
  context 'a method with parens' do
    it 'is not violated for a method with a single argument' do
      expect(%{def doctor(who)}).not_to violate(MethodParensRule)
    end

    it 'is not violated for a method with multiple arguments' do
      expect(%{def who?(are_you, who_who)}).not_to violate(MethodParensRule)
    end

    it 'is violated for a method with parens but no arguments' do
      expect(%{def nonsense()}).to violate(MethodParensRule)
    end
  end

  context 'a method without parens' do
    it 'is not violated for a method with no arguments' do
      expect(%(def chuck_norris)).not_to violate(MethodParensRule)
    end

    it 'is violated for a method with an argument' do
      expect(%(def valid ruby)).to violate(MethodParensRule)
    end
  end
end
