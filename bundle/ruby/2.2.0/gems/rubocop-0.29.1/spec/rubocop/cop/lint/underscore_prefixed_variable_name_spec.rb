# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::UnderscorePrefixedVariableName do
  subject(:cop) { described_class.new }

  before do
    inspect_source(cop, source)
  end

  context 'when an underscore-prefixed variable is used' do
    let(:source) { <<-END }
      def some_method
        _foo = 1
        puts _foo
      end
    END

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Do not use prefix `_` for a variable that is used.')
      expect(cop.offenses.first.severity.name).to eq(:warning)
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['_foo'])
    end
  end

  context 'when non-underscore-prefixed variable is used' do
    let(:source) { <<-END }
      def some_method
        foo = 1
        puts foo
      end
    END

    it 'accepts' do
      expect(cop.offenses).to be_empty
    end
  end

  context 'when an underscore-prefixed variable is reassigned' do
    let(:source) { <<-END }
      def some_method
        _foo = 1
        _foo = 2
      end
    END

    it 'accepts' do
      expect(cop.offenses).to be_empty
    end
  end

  context 'when an underscore-prefixed method argument is used' do
    let(:source) { <<-END }
      def some_method(_foo)
        puts _foo
      end
    END

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['_foo'])
    end
  end

  context 'when an underscore-prefixed block argument is used' do
    let(:source) { <<-END }
      1.times do |_foo|
        puts _foo
      end
    END

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['_foo'])
    end
  end

  context 'when an underscore-prefixed variable in top-level scope is used' do
    let(:source) { <<-END }
      _foo = 1
      puts _foo
    END

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['_foo'])
    end
  end

  context 'when an underscore-prefixed variable is captured by a block' do
    let(:source) { <<-END }
      _foo = 1
      1.times do
        _foo = 2
      end
    END

    it 'accepts' do
      expect(cop.offenses).to be_empty
    end
  end

  context 'when an underscore-prefixed named capture variable is used' do
    let(:source) { <<-END }
      /(?<_foo>\\w+)/ =~ 'FOO'
      puts _foo
    END

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['/(?<_foo>\\w+)/'])
    end
  end

  context 'in a method calling `super` without arguments' do
    context 'when an underscore-prefixed argument is not used explicitly' do
      let(:source) { <<-END }
        def some_method(*_)
          super
        end
      END

      it 'accepts' do
        expect(cop.offenses).to be_empty
      end
    end

    context 'when an underscore-prefixed argument is used explicitly' do
      let(:source) { <<-END }
        def some_method(*_)
          super
          puts _
        end
      END

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line).to eq(1)
        expect(cop.highlights).to eq(['_'])
      end
    end
  end

  context 'in a method calling `super` with arguments' do
    context 'when an underscore-prefixed argument is not used' do
      let(:source) { <<-END }
        def some_method(*_)
          super(:something)
        end
      END

      it 'accepts' do
        expect(cop.offenses).to be_empty
      end
    end

    context 'when an underscore-prefixed argument is used explicitly' do
      let(:source) { <<-END }
        def some_method(*_)
          super(*_)
        end
      END

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line).to eq(1)
        expect(cop.highlights).to eq(['_'])
      end
    end
  end
end
