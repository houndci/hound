class RepoConfig
  class ParserError < StandardError
    attr_reader :filename

    def initialize(message, filename:)
      super(message)
      @filename = filename
    end
  end
end
