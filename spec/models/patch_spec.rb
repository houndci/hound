require 'fast_spec_helper'
require 'app/models/patch'
require 'app/models/line'

describe Patch do
  describe '#additions' do
    it 'returns lines that were modified' do
      patch_body = File.read('spec/support/fixtures/patch.diff')
      patch = Patch.new(patch_body)

      expect(patch.additions.size).to eq(3)
      expect(patch.additions.map(&:line_number)).to eq [14, 22, 54]
      expect(patch.additions.map(&:patch_position)).to eq [5, 13, 37]
    end

    context 'when body is nil' do
      it 'returns no additions' do
        patch = Patch.new(nil)

        expect(patch.additions.size).to eq(0)
      end
    end
  end
end
