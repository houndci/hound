require 'fast_spec_helper'
require 'coffeelint'
require 'active_support/core_ext/string/strip'
require 'app/models/coffee_script_style_guide'

describe CoffeeScriptStyleGuide, '#violations' do
  context 'with default configuration' do
    context 'for long line' do
      it 'returns violation' do
        expect(violations_in('1' * 81).first).to match(/exceeds maximum/)
      end
    end

    context 'for trailing whitespace' do
      it 'returns violation' do
        expect(violations_in('1   ').first).to match(/trailing whitespace/)
      end
    end

    context 'for use of tabs' do
      it 'returns violation' do
        expect(violations_in(<<-CODE)).to be_any { |m| m =~ /contains tab/ }
class FooBar
	foo: ->
		"bar"
        CODE
      end
    end

    context 'for inconsistent indentation' do
      it 'returns violation' do
        expect(violations_in(<<-CODE)).to be_any { |m| m =~ /inconsistent/ }
class FooBar
 foo: ->
   "bar"
        CODE
      end
    end

    context 'for conditional modifiers' do
      it 'returns violation'
    end

    context 'for array initialization' do
      it 'returns violation'
    end

    context 'for object initialization' do
      it 'returns violation'
    end

    context 'for hyphen-separated filenames' do
      it 'returns violation'
    end

    context 'for non-PascalCase classes' do
      it 'returns violation' do
        expect(violations_in(<<-CODE)).to be_any { |m| m =~ /camel cased/ }
class strange_ClassNAME
  # implementation intentionally left blank
        CODE
      end
    end

    context 'for non-lowerCamelCase variables and functions' do
      it 'returns violations'
    end

    context 'for non-SCREAMING_SNAKE_CASE constants' do
      it 'returns violations'
    end

    context 'for non-underscore-prefixed private variables and functions' do
      it 'returns violations'
    end

    context 'for use of `is` and `isnt`' do
      it 'returns violations'
    end

    context 'for use of `or` and `and`' do
      it 'returns violation'
    end
  end

  context 'with custom configuration' do
    it 'finds no violations' do
      content = '1' * 110
      file = double(:file, contents: content, filename: 'test.coffee')
      config = <<-TEXT.strip_heredoc
        {
          "max_line_length": {
            "value": 120,
            "level": "error",
            "limitComments": true
          }
        }
      TEXT
      style_guide = CoffeeScriptStyleGuide.new(config)

      violations = style_guide.violations(file)

      expect(violations.map(&:message)).to be_empty
    end
  end

  private

  def violations_in(content)
    unless content.end_with?("\n")
      content += "\n"
    end

    file = double(:file, contents: content, filename: 'test.coffee')
    CoffeeScriptStyleGuide.new.violations(file).map(&:message)
  end
end
