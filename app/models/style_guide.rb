class StyleGuide
  RULES = [
    Rubocop::Cop::Style::AndOr,
    Rubocop::Cop::Style::BlockComments,
    Rubocop::Cop::Style::Blocks,
    Rubocop::Cop::Style::BracesAroundHashParameters,
    Rubocop::Cop::Style::ClassAndModuleCamelCase,
    Rubocop::Cop::Style::ClassMethods,
    Rubocop::Cop::Style::ColonMethodCall,
    Rubocop::Cop::Style::ConstantName,
    Rubocop::Cop::Style::DefWithParentheses,
    Rubocop::Cop::Style::DotPosition,
    Rubocop::Cop::Style::EmptyLineBetweenDefs,
    Rubocop::Cop::Style::EmptyLines,
    Rubocop::Cop::Style::EndOfLine,
    Rubocop::Cop::Style::FinalNewline,
    Rubocop::Cop::Style::HashSyntax,
    Rubocop::Cop::Style::IfWithSemicolon,
    Rubocop::Cop::Style::IndentationWidth,
    Rubocop::Cop::Style::LineLength,
    Rubocop::Cop::Style::MethodCallParentheses,
    Rubocop::Cop::Style::MethodDefParentheses,
    Rubocop::Cop::Style::MethodName,
    Rubocop::Cop::Style::Not,
    Rubocop::Cop::Style::ParenthesesAroundCondition,
    Rubocop::Cop::Style::RedundantBegin,
    Rubocop::Cop::Style::RedundantReturn,
    Rubocop::Cop::Style::RedundantSelf,
    Rubocop::Cop::Style::SpaceAfterColon,
    Rubocop::Cop::Style::SpaceAfterComma,
    Rubocop::Cop::Style::SpaceAfterControlKeyword,
    Rubocop::Cop::Style::SpaceAfterMethodName,
    Rubocop::Cop::Style::SpaceAfterNot,
    Rubocop::Cop::Style::SpaceAfterSemicolon,
    Rubocop::Cop::Style::SpaceAroundEqualsInParameterDefault,
    Rubocop::Cop::Style::SpaceAroundOperators,
    Rubocop::Cop::Style::SpaceBeforeBlockBraces,
    Rubocop::Cop::Style::SpaceBeforeModifierKeyword,
    Rubocop::Cop::Style::SpaceInsideBlockBraces,
    Rubocop::Cop::Style::SpaceInsideBrackets,
    Rubocop::Cop::Style::SpaceInsideHashLiteralBraces,
    Rubocop::Cop::Style::SpaceInsideParens,
    Rubocop::Cop::Style::StringLiterals,
    Rubocop::Cop::Style::Tab,
    Rubocop::Cop::Style::TrailingBlankLines,
    Rubocop::Cop::Style::TrailingWhitespace,
    Rubocop::Cop::Style::UnlessElse,
    Rubocop::Cop::Style::VariableName
  ]

  def initialize(config = nil)
    @config = config
  end

  def violations(file_content)
    investigate(parse_file_content(file_content))
  end

  private

  def investigate(parsed_file_content)
    team = Rubocop::Cop::Team.new(RULES, configuration)
    commissioner = Rubocop::Cop::Commissioner.new(team.cops)
    commissioner.investigate(parsed_file_content)
  end

  def parse_file_content(file_content)
    Rubocop::SourceParser.parse(file_content)
  end

  def configuration
    if @config
      config = YAML.load(@config)
      Rubocop::Config.new(config)
    else
      Rubocop::ConfigLoader.load_file('config/rubocop.yml')
    end
  end
end
