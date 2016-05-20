# encoding: utf-8

require 'spec_helper'

describe 'isolated environment', :isolated_environment do
  include FileHelper

  let(:cli) { RuboCop::CLI.new }

  before(:each) { $stdout = StringIO.new }
  after(:each) { $stdout = STDOUT }

  # Configuration files above the work directory shall not disturb the
  # tests. This is especially important on Windows where the temporary
  # directory is under the user's home directory. On any platform we don't want
  # a .rubocop.yml file in the temporary directory to affect the outcome of
  # rspec.
  it 'is not affected by a config file above the work directory' do
    create_file('../.rubocop.yml', ['inherit_from: missing_file.yml'])
    create_file('ex.rb', ['# encoding: utf-8'])
    # A return value of 0 means that the erroneous config file was not read.
    expect(cli.run([])).to eq(0)
  end
end
