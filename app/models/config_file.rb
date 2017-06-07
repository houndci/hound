class ConfigFile
  attr_reader :content, :format

  def initialize(content:, format:)
    @content = content
    @format = format
  end
end
