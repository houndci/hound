require 'fast_spec_helper'
require 'app/models/file_collection'

describe FileCollection do
  describe '#relevant_files' do
    context 'with modified Ruby file that is not ignored' do
      it 'returns collection including file' do
        file = double(:file, removed?: false, ruby?: true, filename: 'test.rb')
        collection = FileCollection.new([file])

        expect(collection.relevant_files).to eq [file]
      end
    end
  end
end
