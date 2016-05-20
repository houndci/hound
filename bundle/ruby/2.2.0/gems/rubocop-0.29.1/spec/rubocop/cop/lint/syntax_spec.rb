# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::Syntax do
  describe '.offense_from_diagnostic' do
    subject(:offense) { described_class.offense_from_diagnostic(diagnostic) }
    let(:diagnostic) { Parser::Diagnostic.new(level, reason, args, location) }
    let(:level) { :warning }
    let(:reason) { :odd_hash }
    let(:args) { [] }
    let(:location) { double('location').as_null_object }

    it 'returns an offense' do
      expect(offense).to be_a(RuboCop::Cop::Offense)
    end

    it "sets diagnostic's level to offense's severity" do
      expect(offense.severity).to eq(level)
    end

    it "sets diagnostic's message to offense's message" do
      expect(offense.message).to eq('odd number of entries for a hash')
    end

    it "sets diagnostic's location to offense's location" do
      expect(offense.location).to eq(location)
    end

    it 'sets Syntax as a cop name' do
      expect(offense.cop_name).to eq('Syntax')
    end
  end
end
