class CoffeeScriptStyleGuide
  def initialize(override_config_content = nil)
    @override_config_content = override_config_content || '{}'
  end

  def violations(file)
    Coffeelint.lint(file.contents, configuration).map do |violation_hash|
      CoffeeLintViolation.new(
        violation_hash.fetch('lineNumber'),
        violation_hash.fetch('message')
      )
    end
  end

  private

  CoffeeLintViolation = Struct.new(:line, :message)

  private_constant :CoffeeLintViolation

  def configuration
    default_config.merge(override_config)
  end

  def default_config
    JSON.parse(File.read('config/coffeelint.json'))
  end

  def override_config
    JSON.parse(@override_config_content)
  end
end
