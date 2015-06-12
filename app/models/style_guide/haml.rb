module StyleGuide
  class Haml < Base
    DEFAULT_CONFIG_FILENAME = "haml.yml"

    def file_review(file)
      @file = file

      FileReview.new(filename: file.filename) do |file_review|
        run_linters.map do |violation|
          line = file.line_at(violation.line)

          file_review.build_violation(line, violation.message)
        end
        file_review.complete
      end
    end

    def file_included?(*)
      true
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
