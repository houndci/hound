require 'fast_spec_helper'
require 'rubocop'
require 'active_support/core_ext/string/strip'
require 'app/models/style_guide'

describe StyleGuide, '#violations' do
  context 'with custom configuration' do
    it 'finds only one violation' do
      content = <<-EOL.strip_heredoc
        def test_method()
          "hello world"
        end
      EOL
      config = <<-EOL.strip_heredoc
        StringLiterals:
          EnforcedStyle: double_quotes
          Enabled: true
      EOL
      style_guide = StyleGuide.new(config)

      violations = style_guide.violations(content)

      expect(violations.map(&:message)).to eq [
        "Omit the parentheses in defs when the method doesn't accept any arguments."
      ]
    end
  end

  context 'with default configuration' do
    describe 'line character limit' do
      it 'does not have violation' do
        expect(violations_in('a' * 80)).to be_empty
      end

      it 'has violation' do
        expect(violations_in('a' * 81)).to eq ['Line is too long. [81/80]']
      end
    end

    describe 'trailing white space' do
      it 'does not have violation' do
        expect(violations_in('def some_method')).to be_empty
      end

      it 'has violation' do
        expect(violations_in('def some_method   ')).
          to eq ['Trailing whitespace detected.']
      end
    end

    describe 'parentheses white space' do
      it 'does not have violation' do
        expect(violations_in('some_method(1)')).to be_empty
      end

      it 'has violation' do
        expect(violations_in('some_method( 1)')).
          to eq ['Space inside parentheses detected.']
      end
    end

    describe 'square brackets white space' do
      it 'does not have violation' do
        content = <<-EOL.strip_heredoc
          def hello
            true
          end
        EOL

        expect(violations_in('[1, 2]')).to be_empty
      end

      it 'has violation' do
        expect(violations_in('[1, 2 ]')).
          to eq ['Space inside square brackets detected.']
      end
    end

    describe 'curly brackets white space' do
      it 'does not have violation' do
        expect(violations_in('{ a: 1, b: 2 }')).to be_empty
      end

      it 'has violation' do
        expect(violations_in('{a: 1, b: 2}')).
          to eq ['Space inside { missing.', 'Space inside } missing.']
      end
    end

    describe 'curly brackets and pipe white space' do
      it 'does not have violation' do
        expect(violations_in('ary.map { |a| a.something }')).to  be_empty
      end

      it 'has violation' do
        expect(violations_in('ary.map{|a| a.something}')).  to eq [
          'Space missing to the left of {.',
          'Space between { and | missing.',
          'Space missing inside }.'
        ]
      end
    end
  end

  private

  def violations_in(content)
    StyleGuide.new.violations("#{content}\n").map(&:message)
  end
end
