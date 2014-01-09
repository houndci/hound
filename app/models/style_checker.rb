class StyleChecker
  FileViolation = Struct.new(:filename, :line_violations)
  LineViolation = Struct.new(:line_number, :code, :messages)

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

  def initialize(files)
    @files = files
  end

  def violations
    possible_violations = @files.map do |file|
      FileViolation.new(file.filename, line_violations(file))
    end

    possible_violations.select do |file_violation|
      file_violation.line_violations.any?
    end
  end

  private

  def line_violations(file)
    violations = violations_in_file(file).select do |violation|
      file.relevant_line?(violation.line)
    end

    violations.group_by(&:line).map do |line_number, violations|
      LineViolation.new(
        line_number,
        line_in_file(line_number, file),
        violations.map(&:message)
      )
    end
  end

  def violations_in_file(file)
    team = Rubocop::Cop::Team.new(RULES, configuration)
    commissioner = Rubocop::Cop::Commissioner.new(team.cops)
    commissioner.investigate(parse_file_content(file))
  end

  def parse_file_content(file)
    Rubocop::SourceParser.parse(file.contents)
  end

  def line_in_file(line_number, file)
    parse_file_content(file).lines[line_number - 1]
  end

  def configuration
    @config ||= Rubocop::ConfigLoader.load_file('config/rubocop.yml')
  end
end
