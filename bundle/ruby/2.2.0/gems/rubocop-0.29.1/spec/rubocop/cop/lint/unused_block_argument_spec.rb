# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::UnusedBlockArgument do
  subject(:cop) { described_class.new }

  context 'inspection' do
    before do
      inspect_source(cop, source)
    end

    context 'when a block takes multiple arguments' do
      context 'and an argument is unused' do
        let(:source) { <<-END }
          hash = { foo: 'FOO', bar: 'BAR' }
          hash.each do |key, value|
            puts key
          end
        END

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Unused block argument - `value`. ' \
            "If it's necessary, use `_` or `_value` as an argument name " \
            "to indicate that it won't be used."
          )
          expect(cop.offenses.first.severity.name).to eq(:warning)
          expect(cop.offenses.first.line).to eq(2)
          expect(cop.highlights).to eq(['value'])
        end
      end

      context 'and all the arguments are unused' do
        let(:source) { <<-END }
          hash = { foo: 'FOO', bar: 'BAR' }
          hash.each do |key, value|
            puts :something
          end
        END

        it 'registers offenses and suggests omitting them' do
          expect(cop.offenses.size).to eq(2)
          expect(cop.offenses.first.message).to eq(
            'Unused block argument - `key`. ' \
            "You can omit all the arguments if you don't care about them."
          )
          expect(cop.offenses.first.line).to eq(2)
          expect(cop.highlights).to eq(%w(key value))
        end
      end
    end

    context 'when a block takes single argument' do
      context 'and the argument is unused' do
        let(:source) { <<-END }
          1.times do |index|
            puts :something
          end
        END

        it 'registers an offense and suggests omitting that' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Unused block argument - `index`. ' \
            "You can omit the argument if you don't care about it."
          )
          expect(cop.offenses.first.line).to eq(1)
          expect(cop.highlights).to eq(['index'])
        end
      end
    end

    context 'when a block have a block local variable' do
      context 'and the variable is unused' do
        let(:source) { <<-END }
          1.times do |index; block_local_variable|
            puts index
          end
        END

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Unused block local variable - `block_local_variable`.'
          )
          expect(cop.offenses.first.line).to eq(1)
          expect(cop.highlights).to eq(['block_local_variable'])
        end
      end
    end

    context 'when a lambda block takes arguments' do
      context 'and all the arguments are unused' do
        let(:source) { <<-END }
          -> (foo, bar) { do_something }
        END

        it 'registers offenses and suggests using a proc' do
          expect(cop.offenses.size).to eq(2)
          expect(cop.offenses.first.message).to eq(
            'Unused block argument - `foo`. ' \
            "If it's necessary, use `_` or `_foo` as an argument name " \
            "to indicate that it won't be used. " \
            'Also consider using a proc without arguments instead of a ' \
            "lambda if you want it to accept any arguments but don't care " \
            'about them.'

          )
          expect(cop.offenses.first.line).to eq(1)
          expect(cop.highlights).to eq(%w(foo bar))
        end
      end

      context 'and an arguments is unused' do
        let(:source) { <<-END }
          -> (foo, bar) { puts bar }
        END

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Unused block argument - `foo`. ' \
            "If it's necessary, use `_` or `_foo` as an argument name " \
            "to indicate that it won't be used."
          )
          expect(cop.offenses.first.line).to eq(1)
          expect(cop.highlights).to eq(['foo'])
        end
      end
    end

    context 'when an underscore-prefixed block argument is not used' do
      let(:source) { <<-END }
        1.times do |_index|
          puts 'foo'
        end
      END

      it 'accepts' do
        expect(cop.offenses).to be_empty
      end
    end

    context 'when a method argument is not used' do
      let(:source) { <<-END }
        def some_method(foo)
        end
      END

      it 'does not care' do
        expect(cop.offenses).to be_empty
      end
    end

    context 'when a variable is not used' do
      let(:source) { <<-END }
        1.times do
          foo = 1
        end
      END

      it 'does not care' do
        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'auto-correct' do
    it 'fixes single' do
      expect(autocorrect_source(cop, <<-SOURCE
      arr.map { |foo| stuff }
      SOURCE
      )).to eq(<<-CORRECTED_SOURCE
      arr.map { |_foo| stuff }
      CORRECTED_SOURCE
      )
    end

    it 'fixes multiple' do
      expect(autocorrect_source(cop, <<-SOURCE
      hash.map { |key, val| stuff }
      SOURCE
      )).to eq(<<-CORRECTED_SOURCE
      hash.map { |_key, _val| stuff }
      CORRECTED_SOURCE
      )
    end

    it 'preserves whitespace' do
      expect(autocorrect_source(cop, <<-SOURCE
      hash.map { |key,
                  val| stuff }
      SOURCE
      )).to eq(<<-CORRECTED_SOURCE
      hash.map { |_key,
                  _val| stuff }
      CORRECTED_SOURCE
      )
    end

    it 'preserves splat' do
      expect(autocorrect_source(cop, <<-SOURCE
      obj.method { |foo, *bars, baz| stuff(foo, baz) }
      SOURCE
      )).to eq(<<-CORRECTED_SOURCE
      obj.method { |foo, *_bars, baz| stuff(foo, baz) }
      CORRECTED_SOURCE
      )
    end

    it 'preserves default' do
      expect(autocorrect_source(cop, <<-SOURCE
      obj.method { |foo, bar = baz| stuff(foo) }
      SOURCE
      )).to eq(<<-CORRECTED_SOURCE
      obj.method { |foo, _bar = baz| stuff(foo) }
      CORRECTED_SOURCE
      )
    end

    it 'ignores used' do
      original_source = <<-SOURCE
      obj.method { |foo, baz| stuff(foo, baz) }
      SOURCE

      expect(autocorrect_source(cop, original_source)).to eq(original_source)
    end
  end
end
