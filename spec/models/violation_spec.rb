require 'fast_spec_helper'
require "app/models/violation"

describe Violation do
  describe '#line_number' do
    it 'returns the line number of the line' do
      line_number = 10
      line = double(:line, line_number: line_number)
      violation = Violation.new("file.rb", line)

      expect(violation.line_number).to eq line_number
    end
  end
end
