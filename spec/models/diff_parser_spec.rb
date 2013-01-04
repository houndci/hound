require File.expand_path('../../../app/models/diff_parser', __FILE__)

describe DiffParser, '#additions' do
  it 'returns all of the lines that were added in a diff' do
    parser = DiffParser.new(example_diff)

    expect(parser.additions).to eq ['line 1', 'line 2+2']
  end

  it 'parses an actual github diff file' do
    diff_path = File.expand_path('../../support/fixtures/sample.diff', __FILE__)
    parser = DiffParser.new(File.open(diff_path))

    expect(parser.additions).to have(165).items
  end

  def example_diff
    @diff ||= StringIO.new <<-TEXT
+  line 1
   line 2
-  line three
+  line 2+2  
    TEXT
  end
end
