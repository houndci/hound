class FileViolation < Struct.new(:filename, :line_violations, :modified_lines)
end
