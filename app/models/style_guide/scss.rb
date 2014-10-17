module StyleGuide
  class Scss < Base
    DEFAULT_CONFIG_FILE = File.join(CONFIG_DIR, "scss.yml")

    def violations_in_file(file)
      if config.excluded_file?(file.filename)
        []
      else
        runner.run([file.content])
        runner.lints.map do |violation|
          Violation.new(file, violation.location.line, violation.description)
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

    def default_options
      @default_options ||= options_hash_from_file(DEFAULT_CONFIG_FILE)
    end

    def options_hash_from_file(file)
      SCSSLint::Config.send(:load_options_hash_from_file, file)
    end

    def merge(a, b)
      SCSSLint::Config.send(:smart_merge, a, b)
    end
  end
end
