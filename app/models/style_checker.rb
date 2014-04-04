class StyleChecker
  RULES = [
    Rubocop::Cop::Style::AndOr,
    Rubocop::Cop::Style::Blocks,
    Rubocop::Cop::Style::BlockComments,
    Rubocop::Cop::Style::BracesAroundHashParameters,
    Rubocop::Cop::Style::ClassAndModuleCamelCase,
    Rubocop::Cop::Style::ClassMethods,
    Rubocop::Cop::Style::ColonMethodCall,
    Rubocop::Cop::Style::ConstantName,
    Rubocop::Cop::Style::DefWithParentheses,
    Rubocop::Cop::Style::DefWithoutParentheses,
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
    Rubocop::Cop::Style::MethodName,
    Rubocop::Cop::Style::Not,
    Rubocop::Cop::Style::ParenthesesAroundCondition,
    Rubocop::Cop::Style::ReduceArguments,
    Rubocop::Cop::Style::RedundantBegin,
    Rubocop::Cop::Style::RedundantSelf,
    Rubocop::Cop::Style::RedundantReturn,
    Rubocop::Cop::Style::SpaceAroundOperators,
    Rubocop::Cop::Style::SpaceAroundBlockBraces,
    Rubocop::Cop::Style::SpaceInsideParens,
    Rubocop::Cop::Style::SpaceInsideBrackets,
    Rubocop::Cop::Style::SpaceAfterColon,
    Rubocop::Cop::Style::SpaceAfterComma,
    Rubocop::Cop::Style::SpaceAfterControlKeyword,
    Rubocop::Cop::Style::SpaceAfterMethodName,
    Rubocop::Cop::Style::SpaceAfterNot,
    Rubocop::Cop::Style::SpaceAfterSemicolon,
    Rubocop::Cop::Style::SpaceAroundEqualsInParameterDefault,
    Rubocop::Cop::Style::SpaceBeforeModifierKeyword,
    Rubocop::Cop::Style::SpaceInsideHashLiteralBraces,
    Rubocop::Cop::Style::StringLiterals,
    Rubocop::Cop::Style::SymbolName,
    Rubocop::Cop::Style::Tab,
    Rubocop::Cop::Style::TrailingBlankLines,
    Rubocop::Cop::Style::TrailingWhitespace,
    Rubocop::Cop::Style::UnlessElse,
    Rubocop::Cop::Style::VariableName
  ]

  def initialize(modified_files, custom_config = nil)
    @modified_files = modified_files
    @custom_config = custom_config
  end

  def violations
    possible_violations = @modified_files.map do |modified_file|
      FileViolation.new(
        modified_file.filename,
        line_violations(modified_file)
      )
    end

    possible_violations.select do |file_violation|
      file_violation.line_violations.any?
    end
  end

  private

  def line_violations(modified_file)
    violations = violations_in_file(modified_file).select do |violation|
      modified_file.relevant_line?(violation.line)
    end

    violations.group_by(&:line).map do |line_number, violations|
      LineViolation.new(
        modified_file.modified_line_at(line_number),
        violations.map(&:message).uniq
      )
    end
  end

  def violations_in_file(modified_file)
    team = Rubocop::Cop::Team.new(RULES, configuration)
    commissioner = Rubocop::Cop::Commissioner.new(team.cops)
    commissioner.investigate(parse_file_content(modified_file))
  end

  def parse_file_content(modified_file)
    Rubocop::SourceParser.parse(modified_file.contents)
  end

  def configuration
    if @custom_config
      config = YAML.load(@custom_config)
      Rubocop::Config.new(config)
    else
      Rubocop::ConfigLoader.load_file('config/rubocop.yml')
    end
  end
end
