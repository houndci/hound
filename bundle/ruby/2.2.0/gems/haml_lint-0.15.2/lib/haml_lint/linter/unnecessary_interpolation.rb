module HamlLint
  # Checks for unnecessary uses of string interpolation.
  #
  # For example, the following two code snippets are equivalent, but the latter
  # is more concise (and thus preferred):
  #
  #   %tag #{expression}
  #   %tag= expression
  class Linter::UnnecessaryInterpolation < Linter
    include LinterRegistry

    def visit_tag(node)
      return if node.script.empty?

      count = 0
      chars = 2 # Include surrounding quote chars
      HamlLint::Utils.extract_interpolated_values(node.script) do |interpolated_code, _line|
        count += 1
        return if count > 1 # rubocop:disable Lint/NonLocalExitFromIterator
        chars += interpolated_code.length + 3
      end

      if chars == node.script.length
        record_lint(node, '`%... \#{expression}` can be written without ' \
                          'interpolation as `%...= expression`')
      end
    end
  end
end
