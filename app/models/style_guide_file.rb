class StyleGuideFile
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

  attr_reader :filename, :contents

  def initialize(filename, contents, modified_line_numbers)
    @filename = filename
    @contents = contents
    @modified_line_numbers = modified_line_numbers
  end

  def violations
    cops = RULES.map {|rule| rule.new}
    commissioner = Rubocop::Cop::Commissioner.new(cops)
    offenses = commissioner.investigate(source).select do |offense|
      modified_line_number?(offense.line)
    end

    offenses.map do |offense|
      {
        line_number: offense.line,
        code: line_of_code(offense.line),
        message: offense.message
      }
    end
  end

  private

  def line_of_code(line_number)
    source.lines[line_number - 1]
  end

  def modified_line_number?(line_number)
    @modified_line_numbers.include?(line_number)
  end

  def source
    @source ||= Rubocop::SourceParser.parse(@contents)
  end
end
