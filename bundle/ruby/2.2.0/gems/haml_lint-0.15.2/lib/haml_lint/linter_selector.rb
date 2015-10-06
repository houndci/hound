module HamlLint
  # Chooses the appropriate linters to run given the specified configuration.
  class LinterSelector
    # Creates a selector using the given configuration and additional options.
    #
    # @param config [HamlLint::Configuration]
    # @param options [Hash]
    def initialize(config, options)
      @config = config
      @options = options
    end

    # Returns the set of linters to run against the given file.
    #
    # @param file [String]
    # @raise [HamlLint::Exceptions::NoLintersError] when no linters are enabled
    # @return [Array<HamlLint::Linter>]
    def linters_for_file(file)
      @linters ||= extract_enabled_linters(@config, @options)
      @linters.select { |linter| run_linter_on_file?(@config, linter, file) }
    end

    private

    # Returns a list of linters that are enabled given the specified
    # configuration and additional options.
    #
    # @param config [HamlLint::Configuration]
    # @param options [Hash]
    # @return [Array<HamlLint::Linter>]
    def extract_enabled_linters(config, options)
      included_linters = LinterRegistry
        .extract_linters_from(options.fetch(:included_linters, []))

      included_linters = LinterRegistry.linters if included_linters.empty?

      excluded_linters = LinterRegistry
        .extract_linters_from(options.fetch(:excluded_linters, []))

      # After filtering out explicitly included/excluded linters, only include
      # linters which are enabled in the configuration
      linters = (included_linters - excluded_linters).map do |linter_class|
        linter_config = config.for_linter(linter_class)
        linter_class.new(linter_config) if linter_config['enabled']
      end.compact

      # Highlight condition where all linters were filtered out, as this was
      # likely a mistake on the user's part
      if linters.empty?
        raise HamlLint::Exceptions::NoLintersError, 'No linters specified'
      end

      linters
    end

    # Whether to run the given linter against the specified file.
    #
    # @param config [HamlLint::Configuration]
    # @param linter [HamlLint::Linter]
    # @param file [String]
    # @return [Boolean]
    def run_linter_on_file?(config, linter, file)
      linter_config = config.for_linter(linter)

      if linter_config['include'].any? &&
         !HamlLint::Utils.any_glob_matches?(linter_config['include'], file)
        return false
      end

      if HamlLint::Utils.any_glob_matches?(linter_config['exclude'], file)
        return false
      end

      true
    end
  end
end
