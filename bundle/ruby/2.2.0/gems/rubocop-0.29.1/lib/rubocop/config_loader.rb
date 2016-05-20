# encoding: utf-8

require 'yaml'
require 'pathname'

module RuboCop
  # This class represents the configuration of the RuboCop application
  # and all its cops. A Config is associated with a YAML configuration
  # file from which it was read. Several different Configs can be used
  # during a run of the rubocop program, if files in several
  # directories are inspected.
  class ConfigLoader
    DOTFILE = '.rubocop.yml'
    RUBOCOP_HOME = File.realpath(File.join(File.dirname(__FILE__), '..', '..'))
    DEFAULT_FILE = File.join(RUBOCOP_HOME, 'config', 'default.yml')
    AUTO_GENERATED_FILE = '.rubocop_todo.yml'

    class << self
      attr_accessor :debug, :auto_gen_config
      attr_writer :root_level # The upwards search is stopped at this level.

      alias_method :debug?, :debug
      alias_method :auto_gen_config?, :auto_gen_config

      def load_file(path)
        path = File.absolute_path(path)
        hash = load_yaml_configuration(path)

        resolve_inheritance(path, hash)

        Array(hash.delete('require')).each { |r| require(r) }

        hash.delete('inherit_from')
        config = Config.new(hash, path)

        config.deprecation_check do |deprecation_message|
          warn("#{path} - #{deprecation_message}")
        end

        config.add_missing_namespaces
        config.warn_unless_valid
        config.make_excludes_absolute
        config
      end

      # Return a recursive merge of two hashes. That is, a normal hash merge,
      # with the addition that any value that is a hash, and occurs in both
      # arguments, will also be merged. And so on.
      def merge(base_hash, derived_hash)
        result = base_hash.merge(derived_hash)
        keys_appearing_in_both = base_hash.keys & derived_hash.keys
        keys_appearing_in_both.each do |key|
          next unless base_hash[key].is_a?(Hash)
          result[key] = merge(base_hash[key], derived_hash[key])
        end
        result
      end

      def base_configs(path, inherit_from)
        configs = Array(inherit_from).map do |f|
          f = File.expand_path(f, File.dirname(path))

          if auto_gen_config?
            next if f.include?(AUTO_GENERATED_FILE)
            old_auto_config_file_warning if f.include?('rubocop-todo.yml')
          end

          print 'Inheriting ' if debug?
          load_file(f)
        end

        configs.compact
      end

      # Returns the path of .rubocop.yml searching upwards in the
      # directory structure starting at the given directory where the
      # inspected file is. If no .rubocop.yml is found there, the
      # user's home directory is checked. If there's no .rubocop.yml
      # there either, the path to the default file is returned.
      def configuration_file_for(target_dir)
        config_files_in_path(target_dir).first || DEFAULT_FILE
      end

      def configuration_from_file(config_file)
        config = load_file(config_file)
        return config if config_file == DEFAULT_FILE

        found_files = config_files_in_path(config_file)
        if found_files.any? && found_files.last != config_file
          print 'AllCops/Exclude ' if debug?
          config.add_excludes_from_higher_level(load_file(found_files.last))
        end
        merge_with_default(config, config_file)
      end

      def default_configuration
        @default_configuration ||= begin
                                     print 'Default ' if debug?
                                     load_file(DEFAULT_FILE)
                                   end
      end

      def merge_with_default(config, config_file)
        Config.new(merge(default_configuration, config), config_file)
      end

      private

      def load_yaml_configuration(absolute_path)
        yaml_code = IO.read(absolute_path)
        # At one time, there was a problem with the psych YAML engine under
        # Ruby 1.9.3. YAML.load_file would crash when reading empty .yml files
        # or files that only contained comments and blank lines. This problem
        # is not possible to reproduce now, but we want to avoid it in case
        # it's still there. So we only load the YAML code if we find some real
        # code in there.
        hash = yaml_code =~ /^[A-Z]/i ? YAML.load(yaml_code) : {}
        puts "configuration from #{absolute_path}" if debug?

        unless hash.is_a?(Hash)
          fail(TypeError, "Malformed configuration in #{absolute_path}")
        end

        hash
      end

      def resolve_inheritance(path, hash)
        base_configs(path, hash['inherit_from']).reverse_each do |base_config|
          base_config.each do |k, v|
            hash[k] = hash.key?(k) ? merge(v, hash[k]) : v if v.is_a?(Hash)
          end
        end
      end

      def config_files_in_path(target)
        possible_config_files = dirs_to_search(target).map do |dir|
          File.join(dir, DOTFILE)
        end
        possible_config_files.select { |config_file| File.exist?(config_file) }
      end

      def dirs_to_search(target_dir)
        dirs_to_search = []
        Pathname.new(File.expand_path(target_dir)).ascend do |dir_pathname|
          break if dir_pathname.to_s == @root_level
          dirs_to_search << dir_pathname.to_s
        end
        dirs_to_search << Dir.home
      end

      def old_auto_config_file_warning
        warn 'Attention: rubocop-todo.yml has been renamed to ' \
             "#{AUTO_GENERATED_FILE}".color(:red)
        exit(1)
      end
    end
  end
end
