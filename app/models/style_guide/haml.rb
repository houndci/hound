module StyleGuide
  class Haml < Base
    DEFAULT_CONFIG_FILENAME = "haml.yml"

    def violations_in_file(file)
      @file = file

      run_linters.map do |violation|
        violations_in_line(violation)
      end
    end

    private

    attr_reader :file

    def parser
      @parser ||= HamlLint::Parser.new(file.content, {})
    end

    def run_linters
      linters.reduce([]) do |results, linter|
        linter.run(parser)
        results + linter.lints
      end
    end

    def linters
      included_linters = HamlLint::LinterRegistry.linters

      @linters ||= included_linters.map do |linter_class|
        linter_config = config.for_linter(linter_class)

        if linter_config.fetch("enabled", false)
          linter_class.new(linter_config)
        end
      end.compact
    end

    def violations_in_line(violation)
      line = file.line_at(violation.line)

      Violation.new(
        filename: file.filename,
        line: line,
        line_number: violation.line,
        messages: [violation.message],
        patch_position: line.patch_position,
      )
    end

    def config
      default_config.merge(custom_config)
    end

    def custom_config
      HamlLint::Configuration.new(repo_config.for(name))
    end

    def default_config
      HamlLint::ConfigurationLoader.load_file(default_config_file)
    end

    def default_config_file
      DefaultConfigFile.new(
        DEFAULT_CONFIG_FILENAME,
        repository_owner_name
      ).path
    end
  end
end
