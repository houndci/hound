module HamlLint
  # Checks scripts spread over multiple lines.
  class Linter::MultilineScript < Linter
    include LinterRegistry

    # List of operators that can split a script into two lines that we want to
    # alert on.
    SPLIT_OPERATORS = %w[
      || or && and
      ||= &&=
      ^ << >> | &
      <<= >>= |= &=
      + - * / ** %
      += -= *= /= **= %=
      < <= <=> >= >
      = == === != =~ !~
      .. ...
      ? :
      not
      if unless while until
      begin
    ].to_set

    def visit_script(node)
      check(node)
    end

    def visit_silent_script(node)
      check(node)
    end

    private

    def check(node)
      operator = node.script[/\s+(\S+)\z/, 1]
      if SPLIT_OPERATORS.include?(operator)
        record_lint(node,
                    "Script with trailing operator `#{operator}` should be " \
                    'merged with the script on the following line')
      end
    end
  end
end
