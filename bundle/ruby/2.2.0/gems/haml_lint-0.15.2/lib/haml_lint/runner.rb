module HamlLint
  # Responsible for running the applicable linters against the desired files.
  class Runner
    # Runs the appropriate linters against the desired files given the specified
    # options.
    #
    # @param [Hash] options
    # @option options :config_file [String] path of configuration file to load
    # @option options :config [HamlLint::Configuration] configuration to use
    # @option options :excluded_files [Array<String>]
    # @option options :included_linters [Array<String>]
    # @option options :excluded_linters [Array<String>]
    # @return [HamlLint::Report] a summary of all lints found
    def run(options = {})
      config = load_applicable_config(options)
      files = extract_applicable_files(config, options)

      linter_selector = HamlLint::LinterSelector.new(config, options)

      lints = files.map do |file|
        collect_lints(file, linter_selector, config)
      end.flatten

      HamlLint::Report.new(lints, files)
    end

    private

    # Returns the {HamlLint::Configuration} that should be used given the
    # specified options.
    #
    # @param options [Hash]
    # @return [HamlLint::Configuration]
    def load_applicable_config(options)
      if options[:config_file]
        HamlLint::ConfigurationLoader.load_file(options[:config_file])
      elsif options[:config]
        options[:config]
      else
        HamlLint::ConfigurationLoader.load_applicable_config
      end
    end

    # Runs all provided linters using the specified config against the given
    # file.
    #
    # @param file [String] path to file to lint
    # @param linter_selector [HamlLint::LinterSelector]
    # @param config [HamlLint::Configuration]
    def collect_lints(file, linter_selector, config)
      begin
        document = HamlLint::Document.new(File.read(file), file: file, config: config)
      rescue HamlLint::Exceptions::ParseError => ex
        return [HamlLint::Lint.new(nil, file, ex.line, ex.to_s, :error)]
      end

      linter_selector.linters_for_file(file).map do |linter|
        linter.run(document)
      end.flatten
    end

    # Returns the list of files that should be linted given the specified
    # configuration and options.
    #
    # @param config [HamlLint::Configuration]
    # @param options [Hash]
    # @return [Array<String>]
    def extract_applicable_files(config, options)
      included_patterns = options[:files]
      excluded_patterns = config['exclude']
      excluded_patterns += options.fetch(:excluded_files, [])

      HamlLint::FileFinder.new(config).find(included_patterns, excluded_patterns)
    end
  end
end
