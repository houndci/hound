require 'fast_spec_helper'
require 'base64'
require 'app/models/modified_file'
require 'app/models/patch'

describe ModifiedFile, '#contents' do
  it 'returns file contents' do
    file = double(:file, status: 'added', filename: 'test1.rb')
    pull_request = double(:pull_request, file_contents: 'test')
    modified_file = ModifiedFile.new(file, pull_request)

    contents = modified_file.contents

    expect(contents).to eq 'test'
  end
end

describe ModifiedFile, '#relevant_line?' do
  context 'when line is modified' do
    it 'returns true' do
      file = double(:file, patch: '')
      modified_file = ModifiedFile.new(file, double)
      modified_line = double(:modified_line, line_number: 1)
      patch = double(:patch, additions: [modified_line])
      Patch.stub(new: patch)

      result = modified_file.relevant_line?(1)

      expect(result).to be_true
    end
  end

  context 'when line is not modified' do
    it 'returns true' do
      file = double(:file, patch: '')
      modified_file = ModifiedFile.new(file, double)
      modified_line = double(:modified_line, line_number: 1)
      patch = double(:patch, additions: [modified_line])
      Patch.stub(new: patch)

      result = modified_file.relevant_line?(2)

      expect(result).to be_false
    end
  end
end

describe ModifiedFile, '#removed?' do
  context 'when status is removed' do
    it 'returns true' do
      file = double(:file, status: 'removed')
      modified_file = ModifiedFile.new(file, double)

      expect(modified_file).to be_removed
    end
  end

  context 'when status is added' do
    it 'returns false' do
      file = double(:file, status: 'added')
      modified_file = ModifiedFile.new(file, double)

      expect(modified_file).not_to be_removed
    end
  end
end

describe ModifiedFile, '#renamed?' do
  context 'when status is renamed' do
    it 'returns true' do
      file = double(:file, status: 'renamed')
      modified_file = ModifiedFile.new(file, double)

      expect(modified_file).to be_renamed
    end
  end
end

describe ModifiedFile, '#ruby?' do
  context 'when file is non-ruby' do
    it 'returns false for json' do
      json_file = double(:file, filename: 'app/models/user.json')
      css_file = double(:file, filename: 'public/main.css.scss')
      modified_file1 = ModifiedFile.new(json_file, double)
      modified_file2 = ModifiedFile.new(css_file, double)

      expect(modified_file1).not_to be_ruby
      expect(modified_file2).not_to be_ruby
    end
  end

  context 'when file is ruby' do
    it 'returns true' do
      ruby_file = double(:file, filename: 'app/models/user.rb')
      modified_file = ModifiedFile.new(ruby_file, double)

      expect(modified_file).to be_ruby
    end
  end
end

describe ModifiedFile, '#modified_line_at' do
  context 'with a modified line' do
    it 'returns modified line at the given line number' do
      modified_line = double(:modified_line, line_number: 1)
      patch = double(:patch, additions: [modified_line])
      Patch.stub(new: patch)
      file = double(:file).as_null_object
      modified_file = ModifiedFile.new(file, double)

      expect(modified_file.modified_line_at(1)).to eq modified_line
    end
  end

  context 'without a modified line' do
    it 'returns nil' do
      modified_line = double(:modified_line, line_number: 1)
      patch = double(:patch, additions: [modified_line])
      Patch.stub(new: patch)
      file = double(:file).as_null_object
      modified_file = ModifiedFile.new(file, double)

      expect(modified_file.modified_line_at(2)).to be_nil
    end
  end
end
