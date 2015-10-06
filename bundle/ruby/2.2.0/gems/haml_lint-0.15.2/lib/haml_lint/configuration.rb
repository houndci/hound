module HamlLint
  # Stores runtime configuration for the application.
  #
  # The purpose of this class is to validate and ensure all configurations
  # satisfy some basic pre-conditions so other parts of the application don't
  # have to check the configuration for errors. It should have no knowledge of
  # how these configuration values are ultimately used.
  class Configuration
    # Internal hash storing the configuration.
    attr_reader :hash

    # Creates a configuration from the given options hash.
    #
    # @param options [Hash]
    def initialize(options)
      @hash = options
      validate
    end

    # Access the configuration as if it were a hash.
    #
    # @param key [String]
    # @return [Array,Hash,Number,String]
    def [](key)
      @hash[key]
    end

    # Compares this configuration with another.
    #
    # @param other [HamlLint::Configuration]
    # @return [true,false] whether the given configuration is equivalent
    def ==(other)
      super || @hash == other.hash
    end
    alias_method :eql?, :==

    # Returns a non-modifiable configuration for the specified linter.
    #
    # @param linter [HamlLint::Linter,Class]
    def for_linter(linter)
      linter_name =
        case linter
        when Class
          linter.name.split('::').last
        when HamlLint::Linter
          linter.name
        end

      @hash['linters'].fetch(linter_name, {}).dup.freeze
    end

    # Merges the given configuration with this one, returning a new
    # {Configuration}. The provided configuration will either add to or replace
    # any options defined in this configuration.
    #
    # @param config [HamlLint::Configuration]
    def merge(config)
      self.class.new(smart_merge(@hash, config.hash))
    end

    private

    # Merge two hashes such that nested hashes are merged rather than replaced.
    #
    # @param parent [Hash]
    # @param child [Hash]
    # @return [Hash]
    def smart_merge(parent, child)
      parent.merge(child) do |_key, old, new|
        case old
        when Hash
          smart_merge(old, new)
        else
          new
        end
      end
    end

    # Validates the configuration for any invalid options, normalizing it where
    # possible.
    def validate
      ensure_exclude_option_array_exists
      ensure_linter_section_exists
      ensure_linter_include_exclude_arrays_exist
      ensure_linter_severity_valid
    end

    # Ensures the `exclude` global option is an array.
    def ensure_exclude_option_array_exists
      @hash['exclude'] = Array(@hash['exclude'])
    end

    # Ensures the `linters` configuration section exists.
    def ensure_linter_section_exists
      @hash['linters'] ||= {}
    end

    # Ensure `include` and `exclude` options for linters are arrays
    # (since users can specify a single string glob pattern for convenience)
    def ensure_linter_include_exclude_arrays_exist
      @hash['linters'].keys.each do |linter_name|
        %w[include exclude].each do |option|
          linter_config = @hash['linters'][linter_name]
          linter_config[option] = Array(linter_config[option])
        end
      end
    end

    def ensure_linter_severity_valid
      @hash['linters'].each do |linter_name, linter_config|
        severity = linter_config['severity']
        unless [nil, 'warning', 'error'].include?(severity)
          raise HamlLint::Exceptions::ConfigurationError,
                "Invalid severity '#{severity}' specified for #{linter_name}"
        end
      end
    end
  end
end
