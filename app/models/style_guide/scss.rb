module StyleGuide
  class Scss < Base
    DEFAULT_CONFIG_FILE = File.join(CONFIG_DIR, "scss.yml")

    def violations_in_file(file)
      if config.excluded_file?(file.filename)
        []
      else
        runner.run([file.filename])
        runner.lints.map do |violation|
          Violation.new(file, violation.line, violation.message)
        end
      end
    end

    private

    def runner
      SCSSLint::Runner.new(config)
    end

    def config
      @config ||= default_config
    end

    def default_config
      SCSSLint::Config.load(DEFAULT_CONFIG_FILE)
    end
  end
end
