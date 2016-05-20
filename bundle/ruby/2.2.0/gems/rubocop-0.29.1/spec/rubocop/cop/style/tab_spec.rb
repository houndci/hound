# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::Tab do
  subject(:cop) { described_class.new }

  it 'registers an offense for a line indented with tab' do
    inspect_source(cop, "\tx = 0")
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for a line indented with multiple tabs' do
    inspect_source(cop, "\t\t\tx = 0")
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for a line indented with mixed whitespace' do
    inspect_source(cop, " \tx = 0")
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a line with tab in a string' do
    inspect_source(cop, "(x = \"\t\")")
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects a line indented with tab' do
    new_source = autocorrect_source(cop, ["\tx = 0"])
    expect(new_source).to eq('  x = 0')
  end

  it 'auto-corrects a line indented with multiple tabs' do
    new_source = autocorrect_source(cop, ["\t\t\tx = 0"])
    expect(new_source).to eq('      x = 0')
  end

  it 'auto-corrects a line indented with mixed whitespace' do
    new_source = autocorrect_source(cop, [" \tx = 0"])
    expect(new_source).to eq('   x = 0')
  end

  it 'auto-corrects a line with tab in a string indented with tab' do
    new_source = autocorrect_source(cop, ["\t(x = \"\t\")"])
    expect(new_source).to eq("  (x = \"\t\")")
  end
end
