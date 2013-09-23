require 'fast_spec_helper'
require 'app/rules/rule'
require 'app/rules/ternary_operator_rule'

describe TernaryOperatorRule, '#violated?' do
 context 'without ternary operator' do
   it 'is not violated' do
     expect(text_without_ternary_operator).not_to violate(TernaryOperatorRule)
   end
 end

 context 'with ternary operator' do
   it 'is violated' do
     expect(text_with_ternary_operator).to violate(TernaryOperatorRule)
   end
 end

 context 'with nested ternary operators' do
   it 'is violated' do
     expect(text_with_nested_ternary_operators).to violate(TernaryOperatorRule)
   end
 end
end

private

def text_without_ternary_operator
  <<-TEXT
  if Delayed::Job.enqueued?
    return true
  else
    return false
  end
  TEXT
end

def text_with_ternary_operator
  "users.include?('user@example.com') ? true : false"
end

def text_with_nested_ternary_operators
  <<-TEXT
  users.size < 1 ? 'empty' :
    users.include?('user@example.com') ? true :
    false
  TEXT
end
