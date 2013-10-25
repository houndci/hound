require 'fast_spec_helper'
require 'app/rules/rule'
require 'app/rules/brace_rule'

describe BraceRule, '#violated?' do
  context 'with proper syntax' do
    it 'is not violated' do
      example = 'users.map { |user| user.name }'

      expect(example).not_to violate(BraceRule)
    end
  end

  context 'with empty string' do
    it 'is not violated' do
      expect('').not_to violate(BraceRule)
    end
  end

  context 'with braces on separate lines' do
    it 'is not violated' do
      example = <<-TEXT
        users = {
          name: 'test-user',
          email: 'test@example.com'
        }
      TEXT

      expect(example).not_to violate(BraceRule)
    end
  end

  context 'with braces used for string interpolation' do
    it 'is not violated' do
      example = 'callback_url("http://#{ENV[\'HOST\']}")'

      expect(example).not_to violate(BraceRule)
    end
  end

  context 'without whitespace before opening brace' do
    it 'is violated' do
      example = 'users.map{ |user| user.name }'

      expect(example).to violate(BraceRule)
    end
  end

  context 'without whitespace after opening brace' do
    it 'is violated' do
      example = 'users.map {|user| user.name }'

      expect(example).to violate(BraceRule)
    end
  end

  context 'without whitespace before closing brace' do
    it 'is violated' do
      example = 'users.map { |user| user.name}'

      expect(example).to violate(BraceRule)
    end
  end

  context 'with more than one whitespace before closing brace' do
    it 'is violated' do
      example = 'users.map { |user| user.name  }'

      expect(example).to violate(BraceRule)
    end
  end

  context 'with more than one whitespace before opening brace' do
    it 'is violated' do
      example = 'users.map {  |user| user.name }'

      expect(example).to violate(BraceRule)
    end
  end
end
