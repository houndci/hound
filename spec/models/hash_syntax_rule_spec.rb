require 'fast_spec_helper'
require 'app/models/rule'
require 'app/models/hash_syntax_rule'

describe HashSyntaxRule, '#violated?' do
  context 'with hashrocket hash syntax' do
    it 'is violated' do
      text_with_hashrocket_following_symbol = <<-TEXT
        mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
      TEXT

      expect(text_with_hashrocket_following_symbol).to violate(HashSyntaxRule)
    end
  end

  context 'with a hashrocket following an object or method call' do
    it 'is not violated' do
      text_with_hashrocket_following_method_call = <<-TEXT
        mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
      TEXT

      expect(text_with_hashrocket_following_method_call).not_to violate(HashSyntaxRule)
    end
  end

  context 'with a hashrocket following a string' do
    it 'is not violated' do
      text_with_hashrocket_following_string = <<-TEXT
        {
          'user' => {
            'email' => 'user@example.com',
            'name' => 'Test User'
          }
        }
      TEXT

      expect(text_with_hashrocket_following_string).not_to violate(HashSyntaxRule)
    end
  end
end
