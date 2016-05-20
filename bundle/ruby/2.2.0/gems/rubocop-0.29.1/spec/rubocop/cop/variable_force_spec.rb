# encoding: utf-8

require 'spec_helper'
require 'astrolabe/sexp'

describe RuboCop::Cop::VariableForce do
  include Astrolabe::Sexp

  subject(:force) { described_class.new([]) }

  describe '#process_node' do
    before do
      force.variable_table.push_scope(s(:def))
    end

    context 'when processing lvar node' do
      let(:node) { s(:lvar, :foo) }

      context 'when the variable is not yet declared' do
        it 'does not raise error' do
          expect { force.process_node(node) }.not_to raise_error
        end
      end
    end
  end
end
