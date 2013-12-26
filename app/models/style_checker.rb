class StyleChecker
  RULES = [
    Rubocop::Cop::Style::AlignArray,
    Rubocop::Cop::Style::AlignHash,
    Rubocop::Cop::Style::AlignParameters,
    Rubocop::Cop::Style::AndOr,
    Rubocop::Cop::Style::Blocks,
    Rubocop::Cop::Style::BracesAroundHashParameters,
    Rubocop::Cop::Style::ClassAndModuleCamelCase,
    Rubocop::Cop::Style::ClassMethods,
    Rubocop::Cop::Style::ConstantName,
    Rubocop::Cop::Style::DefWithParentheses,
    Rubocop::Cop::Style::DotPosition,
    Rubocop::Cop::Style::EmptyLineBetweenDefs,
    Rubocop::Cop::Style::EmptyLines,
    Rubocop::Cop::Style::EmptyLinesAroundAccessModifier,
    Rubocop::Cop::Style::EmptyLinesAroundBody,
    Rubocop::Cop::Style::EndOfLine,
    Rubocop::Cop::Style::FinalNewline,
    Rubocop::Cop::Style::HashSyntax,
    Rubocop::Cop::Style::IndentationWidth,
    Rubocop::Cop::Style::LineLength,
    Rubocop::Cop::Style::MethodCallParentheses,
    Rubocop::Cop::Style::MethodName,
    Rubocop::Cop::Style::Not,
    Rubocop::Cop::Style::RedundantBegin,
    Rubocop::Cop::Style::RedundantReturn,
    Rubocop::Cop::Style::RedundantSelf,
    Rubocop::Cop::Style::SpaceAfterControlKeyword,
    Rubocop::Cop::Style::SpaceAfterMethodName,
    Rubocop::Cop::Style::SpaceAfterNot,
    Rubocop::Cop::Style::SpaceAroundBlockBraces,
    Rubocop::Cop::Style::SpaceAroundEqualsInParameterDefault,
    Rubocop::Cop::Style::SpaceAroundOperators,
    Rubocop::Cop::Style::SpaceBeforeModifierKeyword,
    Rubocop::Cop::Style::SpaceInsideBrackets,
    Rubocop::Cop::Style::SpaceInsideHashLiteralBraces,
    Rubocop::Cop::Style::SpaceInsideParens,
    Rubocop::Cop::Style::StringLiterals,
    Rubocop::Cop::Style::Tab,
    Rubocop::Cop::Style::TrailingWhitespace,
    Rubocop::Cop::Style::UnlessElse
  ]

  def initialize(files)
    @files = files
  end

  def violations
    @violations ||= @files.map { |file| style_violations(file) }.
      select { |style_violation| style_violation.lines.any? }
  end

  private

  def style_violations(file)
    source = Rubocop::SourceParser.parse(file.contents)
    relevant_offenses = offenses(source).select do |offense|
      file.line_numbers.include?(offense.line)
    end

    StyleViolation.new(file.filename, source.lines, relevant_offenses)
  end

  def offenses(source)
    cops = RULES.map { |rule| rule.new }
    commissioner = Rubocop::Cop::Commissioner.new(cops)
    commissioner.investigate(source)
  end
end
