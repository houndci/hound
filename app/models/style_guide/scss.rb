require "scss_lint"

module StyleGuide
  class Scss < Base
    DEFAULT_CONFIG_FILENAME = "scss.yml"

    def violations_in_file(file)
      if config.excluded_file?(file.filename)
        []
      else
        runner.run([file.content])

        runner.lints.map do |violation|
          Violation.new(
            filename: file.filename,
            line: violation.location.line,
            messages: [violation.description],
          )
        end
      end
    end

    private

    def runner
      @runner ||= SCSSLint::Runner.new(config)
    end

    def config
      SCSSLint::Config.new(custom_options || default_options)
    end

    def custom_options
      if options = repo_config.for(name)
        merge(default_options, options)
      end
    end

    def merge(a, b)
      SCSSLint::Config.send(:smart_merge, a, b)
    end

    def default_options
      @default_options ||= SCSSLint::Config.send(
        :load_options_hash_from_file,
        default_config_file
      )
    end

    def default_config_file
      DefaultConfigFile.new(DEFAULT_CONFIG_FILENAME, repository_owner).path
    end
  end
end
