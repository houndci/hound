module HamlLint
  # Contains information about all lints detected during a scan.
  class Report
    # List of lints that were found.
    attr_accessor :lints

    # List of files that were linted.
    attr_reader :files

    # Creates a report.
    #
    # @param lints [Array<HamlLint::Lint>] lints that were found
    # @param files [Array<String>] files that were linted
    def initialize(lints, files)
      @lints = lints.sort_by { |l| [l.filename, l.line] }
      @files = files
    end

    def failed?
      @lints.any?
    end
  end
end
