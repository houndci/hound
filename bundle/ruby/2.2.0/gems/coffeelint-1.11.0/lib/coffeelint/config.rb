require 'json'

module CoffeeLint
  class Config
    # Looks for existing config files and returns the first match.
    def self.locate
      locations = default_locations

      # handle environment variables
      locations.push(ENV['COFFEELINT_CONFIG']) if ENV['COFFEELINT_CONFIG']
      locations.concat(config_files_in_path(ENV['HOME'])) if ENV['HOME']

      locations.compact.detect { |file| File.exists?(file) }
    end

    # Parses a given JSON file to a Hash.
    def self.parse(file_name)
      JSON.parse(File.read(file_name))
    end

    # Config files CoffeeLint will look for.
    def self.default_locations
      config_files + config_files_in_path('config')
    end
    private_class_method :default_locations

    # Maps config file names in given path/directory.
    def self.config_files_in_path(path)
      config_files.map { |file| File.join([*path, file].compact.reject(&:empty?)) }
    end
    private_class_method :config_files_in_path

    # Config file names CoffeeLint will look for.
    def self.config_files
      %w(
        coffeelint.json
        .coffeelint.json
      )
    end
    private_class_method :config_files
  end
end
