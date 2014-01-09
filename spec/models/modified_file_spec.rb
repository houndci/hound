require 'fast_spec_helper'
require 'base64'
require 'app/models/modified_file'
require 'app/models/diff_patch'

describe ModifiedFile, '#source' do
  it 'returns parsed source' do
    file_contents = double(:file_contents, content: Base64.encode64('test'))
    pull_request_file = double(:pr_file, status: 'added', filename: 'test1.rb')
    pull_request = double(:pull_request, file_contents: file_contents)
    modified_file = ModifiedFile.new(pull_request_file, pull_request)

    source = modified_file.source

    expect(source.lines).to eq Rubocop::SourceParser.parse('test').lines
  end
end

describe ModifiedFile, '#relevant_line?' do
  context 'when line is modified' do
    it 'returns true' do
      pull_request_file = double(:pull_request_file, patch: '')
      modified_file = ModifiedFile.new(pull_request_file, double)
      diff_patch = double(:diff_patch, modified_line_numbers: [1])
      DiffPatch.stub(new: diff_patch)

      result = modified_file.relevant_line?(1)

      expect(result).to be_true
    end
  end

  context 'when line is not modified' do
    it 'returns true' do
      pull_request_file = double(:pull_request_file, patch: '')
      modified_file = ModifiedFile.new(pull_request_file, double)
      diff_patch = double(:diff_patch, modified_line_numbers: [1])
      DiffPatch.stub(new: diff_patch)

      result = modified_file.relevant_line?(2)

      expect(result).to be_false
    end
  end
end

describe ModifiedFile, '#removed?' do
  context 'when status is removed' do
    it 'returns true' do
      pull_request_file = double(:pr_file, status: 'removed')
      modified_file = ModifiedFile.new(pull_request_file, double)

      expect(modified_file).to be_removed
    end
  end

  context 'when status is added' do
    it 'returns false' do
      pull_request_file = double(:pr_file, status: 'added')
      modified_file = ModifiedFile.new(pull_request_file, double)

      expect(modified_file).not_to be_removed
    end
  end
end

describe ModifiedFile, '#ruby?' do
  context 'when file is non-ruby' do
    it 'returns false for json' do
      json_file = double(:pr_file, filename: 'app/models/user.json')
      css_file = double(:pr_file, filename: 'public/main.css.scss')
      modified_file1 = ModifiedFile.new(json_file, double)
      modified_file2 = ModifiedFile.new(css_file, double)

      expect(modified_file1).not_to be_ruby
      expect(modified_file2).not_to be_ruby
    end
  end

  context 'when file is ruby' do
    it 'returns true' do
      ruby_file = double(:pr_file, filename: 'app/models/user.rb')
      modified_file = ModifiedFile.new(ruby_file, double)

      expect(modified_file).to be_ruby
    end
  end
end
