require 'fast_spec_helper'
require 'app/models/rule'
require 'app/models/whitespace_rule'

describe WhitespaceRule, '#violated?' do
  it 'is violated with trailing whitespace' do
    expect(%(def method_name  )).to violate(WhitespaceRule)
  end

  it 'is not violated without trailing whitespace' do
    expect(%(hello = 'world  ')).not_to violate(WhitespaceRule)
  end
end
