module Config
  class ParserError < StandardError
    attr_reader :linter_name

    def initialize(message, linter_name:)
      super(message)
      @linter_name = linter_name
    end
  end
end
