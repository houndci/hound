require 'pathname'
require 'yaml'

module HamlLint
  # Manages configuration file loading.
  class ConfigurationLoader
    DEFAULT_CONFIG_PATH = File.join(HamlLint::HOME, 'config', 'default.yml')
    CONFIG_FILE_NAME = '.haml-lint.yml'

    class << self
      # Load configuration file given the current working directory the
      # application is running within.
      def load_applicable_config
        directory = File.expand_path(Dir.pwd)
        config_file = possible_config_files(directory).find(&:file?)

        if config_file
          load_file(config_file.to_path)
        else
          default_configuration
        end
      end

      # Loads the built-in default configuration.
      def default_configuration
        @default_config ||= load_from_file(DEFAULT_CONFIG_PATH)
      end

      # Loads a configuration, ensuring it extends the default configuration.
      #
      # @param file [String]
      # @return [HamlLint::Configuration]
      def load_file(file)
        config = load_from_file(file)

        default_configuration.merge(config)
      rescue Psych::SyntaxError, Errno::ENOENT => error
        raise HamlLint::Exceptions::ConfigurationError,
              "Unable to load configuration from '#{file}': #{error}",
              error.backtrace
      end

      # Creates a configuration from the specified hash, ensuring it extends the
      # default configuration.
      #
      # @param hash [Hash]
      # @return [HamlLint::Configuration]
      def load_hash(hash)
        config = HamlLint::Configuration.new(hash)

        default_configuration.merge(config)
      end

      private

      # Parses and loads a configuration from the given file.
      #
      # @param file [String]
      # @return [HamlLint::Configuration]
      def load_from_file(file)
        hash =
          if yaml = YAML.load_file(file)
            yaml.to_hash
          else
            {}
          end

        HamlLint::Configuration.new(hash)
      end

      # Returns a list of possible configuration files given the context of the
      # specified directory.
      #
      # @param directory [String]
      # @return [Array<Pathname>]
      def possible_config_files(directory)
        files = Pathname.new(directory)
                        .enum_for(:ascend)
                        .map { |path| path + CONFIG_FILE_NAME }
        files << Pathname.new(CONFIG_FILE_NAME)
      end
    end
  end
end
