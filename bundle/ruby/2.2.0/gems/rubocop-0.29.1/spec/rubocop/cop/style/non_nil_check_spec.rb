# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::NonNilCheck, :config do
  subject(:cop) { described_class.new(config) }

  context 'when not allowing semantic changes' do
    let(:cop_config) do
      {
        'IncludeSemanticChanges' => false
      }
    end

    it 'registers an offense for != nil' do
      inspect_source(cop, 'x != nil')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['!='])
      expect(cop.messages)
        .to eq(['Prefer `!expression.nil?` over `expression != nil`.'])
    end

    it 'does not register an offense for != 0' do
      inspect_source(cop, 'x != 0')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for !x.nil?' do
      inspect_source(cop, '!x.nil?')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for not x.nil?' do
      inspect_source(cop, 'not x.nil?')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense if only expression in predicate' do
      inspect_source(cop, ['def signed_in?',
                           '  !current_user.nil?',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense if only expression in class predicate' do
      inspect_source(cop, ['def Test.signed_in?',
                           '  current_user != nil',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense if last expression in predicate' do
      inspect_source(cop, ['def signed_in?',
                           '  something',
                           '  current_user != nil',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense if last expression in class predicate' do
      inspect_source(cop, ['def Test.signed_in?',
                           '  something',
                           '  current_user != nil',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'autocorrects by changing `!= nil` to `!x.nil?`' do
      corrected = autocorrect_source(cop, 'x != nil')
      expect(corrected).to eq '!x.nil?'
    end

    it 'does not autocorrect by removing non-nil (!x.nil?) check' do
      corrected = autocorrect_source(cop, '!x.nil?')
      expect(corrected).to eq '!x.nil?'
    end

    it 'does not blow up when autocorrecting implicit receiver' do
      corrected = autocorrect_source(cop, '!nil?')
      expect(corrected).to eq '!nil?'
    end
  end

  context 'when allowing semantic changes' do
    subject(:cop) { described_class.new(config) }

    let(:cop_config) do
      {
        'IncludeSemanticChanges' => true
      }
    end

    it 'registers an offense for `!x.nil?`' do
      inspect_source(cop, '!x.nil?')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Explicit non-nil checks are usually redundant.'])
      expect(cop.highlights).to eq(['!x.nil?'])
    end

    it 'does not register an offense for `x.nil?`' do
      inspect_source(cop, 'x.nil?')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for `!x`' do
      inspect_source(cop, '!x')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for `not x.nil?`' do
      inspect_source(cop, 'not x.nil?')
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['not x.nil?'])
    end

    it 'autocorrects by changing `x != nil` to `x`' do
      corrected = autocorrect_source(cop, 'x != nil')
      expect(corrected).to eq 'x'
    end

    it 'autocorrects by changing `!x.nil?` to `x`' do
      corrected = autocorrect_source(cop, '!x.nil?')
      expect(corrected).to eq 'x'
    end

    it 'does not blow up when autocorrecting implicit receiver' do
      corrected = autocorrect_source(cop, '!nil?')
      expect(corrected).to eq 'self'
    end
  end
end
