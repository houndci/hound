module StyleGuide
  class Scss < Base
    DEFAULT_CONFIG_FILENAME = "scss.yml"

    def violations_in_file(file)
      require "scss_lint"

      if config.excluded_file?(file.filename)
        []
      else
        runner = build_runner
        runner.run([file.content])

        runner.lints.map do |violation|
          line = file.line_at(violation.location.line)

          Violation.new(
            filename: file.filename,
            line: line,
            line_number: violation.location.line,
            messages: [violation.description],
            patch_position: line.patch_position,
          )
        end
      end
    end

    private

    def build_runner
      SCSSLint::Runner.new(config)
    end

    def config
      @config ||= SCSSLint::Config.load(
        custom_config_file.path,
        merge_with_default: false
      )
    end

    def custom_config_file
      merged_config = SCSSLint::Config.send(
        :smart_merge,
        default_options,
        custom_config
      )

      Tempfile.create("").tap do |tempfile|
        tempfile.write(merged_config.to_yaml)
        tempfile.rewind
      end
    end

    def custom_config
      repo_config.for(name) || {}
    end

    def default_options
      YAML.load_file(default_config_file)
    end

    def default_config_file
      DefaultConfigFile.new(
        DEFAULT_CONFIG_FILENAME,
        repository_owner_name
      ).path
    end
  end
end
