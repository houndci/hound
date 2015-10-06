module HamlLint
  # Outputs lints in a simple format with the filename, line number, and lint
  # message.
  class Reporter::DefaultReporter < Reporter
    def display_report(report)
      sorted_lints = report.lints.sort_by { |l| [l.filename, l.line] }

      sorted_lints.each do |lint|
        print_location(lint)
        print_type(lint)
        print_message(lint)
      end
    end

    private

    def print_location(lint)
      log.info lint.filename, false
      log.log ':', false
      log.bold lint.line, false
    end

    def print_type(lint)
      if lint.error?
        log.error ' [E] ', false
      else
        log.warning ' [W] ', false
      end
    end

    def print_message(lint)
      if lint.linter
        log.success("#{lint.linter.name}: ", false)
      end

      log.log lint.message
    end
  end
end
