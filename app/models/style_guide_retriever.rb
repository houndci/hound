class StyleGuideRetriever
  COFFEE_SCRIPT_REGEX = /.+\.coffee/
  JAVA_SCRIPT_REGEX = /^((?!\.+).)*\.js\z/
  RUBY_REGEX = /.+\.rb\z/

  def retrieve(filename)
    case filename
    when RUBY_REGEX
      StyleGuide::Ruby
    when COFFEE_SCRIPT_REGEX
      StyleGuide::CoffeeScript
    when JAVA_SCRIPT_REGEX
      StyleGuide::JavaScript
    else
      StyleGuide::Unsupported
    end
  end
end
