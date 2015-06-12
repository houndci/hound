require "scss_lint"

module StyleGuide
  class Scss < Base
    DEFAULT_CONFIG_FILENAME = "scss.yml"

    def file_review(file)
      perform_file_review(file)
    end

    def file_included?(file)
      !config.excluded_file?(file.filename)
    end

    private

    def perform_file_review(file)
      FileReview.new(filename: file.filename) do |file_review|
        runner = build_runner
        runner.run([file.content])

        runner.lints.each do |violation|
          line = file.line_at(violation.location.line)
          file_review.build_violation(line, violation.description)
        end

        file_review.complete
      end
    end

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
