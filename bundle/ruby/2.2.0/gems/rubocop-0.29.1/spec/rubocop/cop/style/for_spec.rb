# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::For, :config do
  subject(:cop) { described_class.new(config) }

  context 'when each is the enforced style' do
    let(:cop_config) { { 'EnforcedStyle' => 'each' } }

    it 'registers an offense for for' do
      inspect_source(cop,
                     ['def func',
                      '  for n in [1, 2, 3] do',
                      '    puts n',
                      '  end',
                      'end'])
      expect(cop.messages).to eq(['Prefer `each` over `for`.'])
      expect(cop.highlights).to eq(['for'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'for')
    end

    it 'registers an offense for opposite + correct style' do
      inspect_source(cop,
                     ['def func',
                      '  for n in [1, 2, 3] do',
                      '    puts n',
                      '  end',
                      '  [1, 2, 3].each do |n|',
                      '    puts n',
                      '  end',
                      'end'])
      expect(cop.messages).to eq(['Prefer `each` over `for`.'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts multiline each' do
      inspect_source(cop,
                     ['def func',
                      '  [1, 2, 3].each do |n|',
                      '    puts n',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts :for' do
      inspect_source(cop, '[:for, :ala, :bala]')
      expect(cop.offenses).to be_empty
    end

    it 'accepts def for' do
      inspect_source(cop, 'def for; end')
      expect(cop.offenses).to be_empty
    end
  end

  context 'when for is the enforced style' do
    let(:cop_config) { { 'EnforcedStyle' => 'for' } }

    it 'accepts for' do
      inspect_source(cop,
                     ['def func',
                      '  for n in [1, 2, 3] do',
                      '    puts n',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for multiline each' do
      inspect_source(cop,
                     ['def func',
                      '  [1, 2, 3].each do |n|',
                      '    puts n',
                      '  end',
                      'end'])
      expect(cop.messages).to eq(['Prefer `for` over `each`.'])
      expect(cop.highlights).to eq(['each'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'each')
    end

    it 'registers an offense for correct + opposite style' do
      inspect_source(cop,
                     ['def func',
                      '  for n in [1, 2, 3] do',
                      '    puts n',
                      '  end',
                      '  [1, 2, 3].each do |n|',
                      '    puts n',
                      '  end',
                      'end'])
      expect(cop.messages).to eq(['Prefer `for` over `each`.'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts single line each' do
      inspect_source(cop,
                     ['def func',
                      '  [1, 2, 3].each { |n| puts n }',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end
end
