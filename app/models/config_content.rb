class ConfigContent
  ContentError = Class.new(StandardError)

  def initialize(commit:, file_path:, parser:)
    @commit = commit
    @file_path = file_path
    @parser = parser
  end

  def load
    if file_path
      parse
    else
      {}
    end
  end

  private

  attr_reader :commit, :file_path, :parser

  def content
    if url?
      remote_content.load
    else
      commit.file_content(file_path)
    end
  end

  def incorrect_format?
    !parsed_content.is_a? Hash
  end

  def parse
    if incorrect_format?
      raise_parse_error
    else
      parsed_content
    end
  end

  def parsed_content
    @_parsed_content ||= parser.call(content)
  rescue Psych::Exception
    raise_parse_error
  end

  def raise_parse_error
    raise Config::ParserError
  end

  def remote_content
    Remote.new(file_path)
  end

  def url?
    URI::regexp(%w(http https)).match(file_path)
  end
end
