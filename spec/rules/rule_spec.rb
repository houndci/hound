require 'fast_spec_helper'
require 'app/rules/rule'

describe Rule, '#violated?' do
  context 'when child class does not implement the method' do
    it 'raises an exception' do
      class TestRule < Rule; end
      rule = TestRule.new

      expect { rule.violated?('code') }.to raise_error(/Must implement #violated\?/)
    end
  end
end
