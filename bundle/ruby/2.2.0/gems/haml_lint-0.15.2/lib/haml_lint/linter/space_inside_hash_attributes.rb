module HamlLint
  # Checks for spaces inside the braces of hash attributes
  # (e.g. `%tag{ lang: en }` vs `%tag{lang: en}`).
  class Linter::SpaceInsideHashAttributes < Linter
    include LinterRegistry

    STYLE = {
      'no_space' => {
        start_regex: /\A\{[^ ]/,
        end_regex: /[^ ]\}\z/,
        start_message: 'Hash attribute should start with no space after the opening brace',
        end_message: 'Hash attribute should end with no space before the closing brace'
      },
      'space' => {
        start_regex: /\A\{ [^ ]/,
        end_regex: /[^ ] \}\z/,
        start_message: 'Hash attribute should start with one space after the opening brace',
        end_message: 'Hash attribute should end with one space before the closing brace'
      }
    }

    def visit_tag(node)
      return unless node.hash_attributes?

      style = STYLE[config['style'] == 'no_space' ? 'no_space' : 'space']
      source = node.hash_attributes_source

      record_lint(node, style[:start_message]) unless source =~ style[:start_regex]
      record_lint(node, style[:end_message]) unless source =~ style[:end_regex]
    end
  end
end
