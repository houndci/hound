# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceAroundBlockParameters, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'common behavior' do
    it 'accepts an empty block' do
      inspect_source(cop, '{}.each {}')
      expect(cop.offenses).to be_empty
    end

    it 'skips lambda without args' do
      inspect_source(cop, '->() { puts "a" }')
      expect(cop.offenses).to be_empty
    end
  end

  context 'when EnforcedStyleInsidePipes is no_space' do
    let(:cop_config) { { 'EnforcedStyleInsidePipes' => 'no_space' } }

    include_examples 'common behavior'

    it 'accepts a block with spaces in the right places' do
      inspect_source(cop, '{}.each { |x, y| puts x }')
      expect(cop.offenses).to be_empty
    end

    it 'accepts a block with parameters but no body' do
      inspect_source(cop, '{}.each { |x, y| }')
      expect(cop.offenses).to be_empty
    end

    it 'accepts a block parameter without preceding space' do
      # This is checked by Style/SpaceAfterComma.
      inspect_source(cop, '{}.each { |x,y| puts x }')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for space before first parameter' do
      inspect_source(cop, '{}.each { | x| puts x }')
      expect(cop.messages)
        .to eq(['Space before first block parameter detected.'])
      expect(cop.highlights).to eq([' '])
    end

    it 'registers an offense for space after last parameter' do
      inspect_source(cop, '{}.each { |x, y  | puts x }')
      expect(cop.messages).to eq(['Space after last block parameter detected.'])
      expect(cop.highlights).to eq(['  '])
    end

    it 'registers an offense for no space after closing pipe' do
      inspect_source(cop, '{}.each { |x, y|puts x }')
      expect(cop.messages).to eq(['Space after closing `|` missing.'])
      expect(cop.highlights).to eq(['|'])
    end

    it 'accepts line break after closing pipe' do
      inspect_source(cop, ['{}.each do |x, y|',
                           '  puts x',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for multiple spaces before parameter' do
      inspect_source(cop, '{}.each { |x,   y| puts x }')
      expect(cop.messages)
        .to eq(['Extra space before block parameter detected.'])
      expect(cop.highlights).to eq(['  '])
    end

    it 'auto-corrects offenses' do
      new_source = autocorrect_source(cop,
                                      '{}.each { |  x=5,  (y,*z) |puts x }')
      expect(new_source).to eq('{}.each { |x=5, (y,*z)| puts x }')
    end
  end

  context 'when EnforcedStyleInsidePipes is space' do
    let(:cop_config) { { 'EnforcedStyleInsidePipes' => 'space' } }

    include_examples 'common behavior'

    it 'accepts a block with spaces in the right places' do
      inspect_source(cop, '{}.each { | x, y | puts x }')
      expect(cop.offenses).to be_empty
    end

    it 'accepts a block with parameters but no body' do
      inspect_source(cop, '{}.each { | x, y | }')
      expect(cop.offenses).to be_empty
    end

    it 'accepts a block parameter without preceding space' do
      # This is checked by Style/SpaceAfterComma.
      inspect_source(cop, '{}.each { | x,y | puts x }')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for no space before first parameter' do
      inspect_source(cop, '{}.each { |x | puts x }')
      expect(cop.messages)
        .to eq(['Space before first block parameter missing.'])
      expect(cop.highlights).to eq(['x'])
    end

    it 'registers an offense for no space after last parameter' do
      inspect_source(cop, '{}.each { | x, y| puts x }')
      expect(cop.messages).to eq(['Space after last block parameter missing.'])
      expect(cop.highlights).to eq(['y'])
    end

    it 'registers an offense for extra space before first parameter' do
      inspect_source(cop, '{}.each { |  x | puts x }')
      expect(cop.messages)
        .to eq(['Extra space before first block parameter detected.'])
      expect(cop.highlights).to eq([' '])
    end

    it 'registers an offense for no space after last parameter' do
      inspect_source(cop, '{}.each { | x, y   | puts x }')
      expect(cop.messages)
        .to eq(['Extra space after last block parameter detected.'])
      expect(cop.highlights).to eq(['  '])
    end

    it 'registers an offense for no space after closing pipe' do
      inspect_source(cop, '{}.each { | x, y |puts x }')
      expect(cop.messages).to eq(['Space after closing `|` missing.'])
      expect(cop.highlights).to eq(['|'])
    end

    it 'accepts line break after closing pipe' do
      inspect_source(cop, ['{}.each do | x, y |',
                           '  puts x',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for multiple spaces before parameter' do
      inspect_source(cop, '{}.each { | x,   y | puts x }')
      expect(cop.messages)
        .to eq(['Extra space before block parameter detected.'])
      expect(cop.highlights).to eq(['  '])
    end

    it 'auto-corrects offenses' do
      new_source = autocorrect_source(cop,
                                      '{}.each { |  x=5,  (y,*z)|puts x }')
      expect(new_source).to eq('{}.each { | x=5, (y,*z) | puts x }')
    end
  end
end
