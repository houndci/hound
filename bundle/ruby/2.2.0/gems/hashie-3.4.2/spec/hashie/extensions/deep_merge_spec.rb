require 'spec_helper'

describe Hashie::Extensions::DeepMerge do
  class DeepMergeHash < Hash
    include Hashie::Extensions::DeepMerge
  end

  subject { DeepMergeHash }

  it 'should return initial hash for arguments that are not hash' do
    hash = subject.new.merge(a: 'a')
    expect(hash.deep_merge('abc')).to eq(hash)
  end

  context 'without &block' do
    let(:h1) { subject.new.merge(a: 'a', a1: 42, b: 'b', c: { c1: 'c1', c2: { a: 'b' }, c3: { d1: 'd1' } }) }
    let(:h2) { { a: 1, a1: 1, c: { c1: 2, c2: 'c2', c3: { d2: 'd2' } } } }
    let(:expected_hash) { { a: 1, a1: 1, b: 'b', c: { c1: 2, c2: 'c2', c3: { d1: 'd1', d2: 'd2' } } } }

    it 'deep merges two hashes' do
      expect(h1.deep_merge(h2)).to eq expected_hash
    end

    it 'deep merges another hash in place via bang method' do
      h1.deep_merge!(h2)
      expect(h1).to eq expected_hash
    end
  end

  context 'with &block' do
    let(:h1) { subject.new.merge(a: 100, b: 200, c: { c1: 100 }) }
    let(:h2) { { b: 250, c: { c1: 200 } } }
    let(:expected_hash) { { a: 100, b: 450, c: { c1: 300 } } }
    let(:block) { proc { |_, this_val, other_val| this_val + other_val } }

    it 'deep merges two hashes' do
      expect(h1.deep_merge(h2, &block)).to eq expected_hash
    end

    it 'deep merges another hash in place via bang method' do
      h1.deep_merge!(h2, &block)
      expect(h1).to eq expected_hash
    end
  end
end
