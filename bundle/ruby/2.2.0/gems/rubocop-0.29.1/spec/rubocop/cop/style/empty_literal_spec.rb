# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::EmptyLiteral do
  subject(:cop) { described_class.new }

  describe 'Empty Array' do
    it 'registers an offense for Array.new()' do
      inspect_source(cop,
                     'test = Array.new()')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use array literal `[]` instead of `Array.new`.'])
    end

    it 'registers an offense for Array.new' do
      inspect_source(cop,
                     'test = Array.new')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use array literal `[]` instead of `Array.new`.'])
    end

    it 'does not register an offense for Array.new(3)' do
      inspect_source(cop,
                     'test = Array.new(3)')
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects Array.new to []' do
      new_source = autocorrect_source(cop, 'test = Array.new')
      expect(new_source).to eq('test = []')
    end
  end

  describe 'Empty Hash' do
    it 'registers an offense for Hash.new()' do
      inspect_source(cop,
                     'test = Hash.new()')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use hash literal `{}` instead of `Hash.new`.'])
    end

    it 'registers an offense for Hash.new' do
      inspect_source(cop,
                     'test = Hash.new')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use hash literal `{}` instead of `Hash.new`.'])
    end

    it 'does not register an offense for Hash.new(3)' do
      inspect_source(cop,
                     'test = Hash.new(3)')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for Hash.new { block }' do
      inspect_source(cop,
                     'test = Hash.new { block }')
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects Hash.new to {}' do
      new_source = autocorrect_source(cop, 'Hash.new')
      expect(new_source).to eq('{}')
    end

    it 'auto-corrects Hash.new to {} in various contexts' do
      new_source =
        autocorrect_source(cop, ['test = Hash.new',
                                 'Hash.new.merge("a" => 3)',
                                 'yadayada.map { a }.reduce(Hash.new, :merge)'])
      expect(new_source)
        .to eq(['test = {}',
                '{}.merge("a" => 3)',
                'yadayada.map { a }.reduce({}, :merge)'].join("\n"))
    end

    it 'does not auto-correct Hash.new to {} if changing code meaning' do
      source = 'yadayada.map { a }.reduce Hash.new, :merge'
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq(source)
    end
  end

  describe 'Empty String' do
    it 'registers an offense for String.new()' do
      inspect_source(cop,
                     'test = String.new()')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(["Use string literal `''` instead of `String.new`."])
    end

    it 'registers an offense for String.new' do
      inspect_source(cop,
                     'test = String.new')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(["Use string literal `''` instead of `String.new`."])
    end

    it 'does not register an offense for String.new("top")' do
      inspect_source(cop,
                     'test = String.new("top")')
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects String.new to empty string literal' do
      new_source = autocorrect_source(cop, 'test = String.new')
      expect(new_source).to eq("test = ''")
    end
  end
end
