require "scss_lint"

module StyleGuide
  class Scss < Base
    BASE_CONFIG_FILE = "config/style_guides/scss.yml"
    CONFIG_FILE = ".scss-style.yml"

    attr_reader :custom_config

    def initialize(config = "")
      @custom_config = YAML.load(config) || {}
    end

    def violations_in_file(file)
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
      SCSSLint::Config.new(merged_config)
    end

    def merged_config
      SCSSLint::Config.send(:smart_merge, base_config, custom_config)
    end

    def base_config
      SCSSLint::Config.send(:load_options_hash_from_file, BASE_CONFIG_FILE)
    end
  end
end
