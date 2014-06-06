require 'fast_spec_helper'
require 'base64'
require 'app/models/commit_file'
require 'app/models/patch'

describe CommitFile, '#relevant_line?' do
  let(:commit_file) { CommitFile.new(double(:file, patch: ''), '') }

  context 'when line is modified' do
    it 'returns true' do
      modified_line = double(:modified_line, line_number: 1)
      patch = double(:patch, additions: [modified_line])
      Patch.stub(new: patch)

      result = commit_file.relevant_line?(1)

      expect(result).to be_true
    end
  end

  context 'when line is not modified' do
    it 'returns false' do
      modified_line = double(:modified_line, line_number: 1)
      patch = double(:patch, additions: [modified_line])
      Patch.stub(new: patch)

      result = commit_file.relevant_line?(2)

      expect(result).to be_false
    end
  end
end

describe CommitFile, '#removed?' do
  context 'when status is removed' do
    it 'returns true' do
      file = double(:file, status: 'removed')
      commit_file = CommitFile.new(file, '')

      expect(commit_file).to be_removed
    end
  end

  context 'when status is added' do
    it 'returns false' do
      file = double(:file, status: 'added')
      commit_file = CommitFile.new(file, '')

      expect(commit_file).not_to be_removed
    end
  end
end

describe CommitFile, '#ruby?' do
  context 'when file is non-ruby' do
    it 'returns false for json' do
      file1 = double(:file, filename: 'app/models/user.json')
      commit_file1 = CommitFile.new(file1, '')
      file2 = double(:file, filename: 'public/main.css.scss')
      commit_file2 = CommitFile.new(file2, '')

      expect(commit_file1).not_to be_ruby
      expect(commit_file2).not_to be_ruby
    end
  end

  context 'when file language is ruby' do
    it 'returns true' do
      file = double(:file, filename: 'app/models/user.rb')
      commit_file = CommitFile.new(file, '')

      expect(commit_file).to be_ruby
    end
  end
end

describe CommitFile, '#modified_line_at' do
  let(:commit_file) { CommitFile.new(double(:file, patch: ''), '') }

  context 'with a modified line' do
    it 'returns modified line at the given line number' do
      modified_line = double(:modified_line, line_number: 1)
      patch = double(:patch, additions: [modified_line])
      Patch.stub(new: patch)

      expect(commit_file.modified_line_at(1)).to eq modified_line
    end
  end

  context 'without a modified line' do
    it 'returns nil' do
      modified_line = double(:modified_line, line_number: 1)
      patch = double(:patch, additions: [modified_line])
      Patch.stub(new: patch)

      expect(commit_file.modified_line_at(2)).to be_nil
    end
  end
end
