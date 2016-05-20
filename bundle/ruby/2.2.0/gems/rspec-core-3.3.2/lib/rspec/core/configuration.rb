RSpec::Support.require_rspec_core "backtrace_formatter"
RSpec::Support.require_rspec_core "ruby_project"
RSpec::Support.require_rspec_core "formatters/deprecation_formatter"

module RSpec
  module Core
    # rubocop:disable Style/ClassLength

    # Stores runtime configuration information.
    #
    # Configuration options are loaded from `~/.rspec`, `.rspec`,
    # `.rspec-local`, command line switches, and the `SPEC_OPTS` environment
    # variable (listed in lowest to highest precedence; for example, an option
    # in `~/.rspec` can be overridden by an option in `.rspec-local`).
    #
    # @example Standard settings
    #     RSpec.configure do |c|
    #       c.drb          = true
    #       c.drb_port     = 1234
    #       c.default_path = 'behavior'
    #     end
    #
    # @example Hooks
    #     RSpec.configure do |c|
    #       c.before(:suite)   { establish_connection }
    #       c.before(:example) { log_in_as :authorized }
    #       c.around(:example) { |ex| Database.transaction(&ex) }
    #     end
    #
    # @see RSpec.configure
    # @see Hooks
    class Configuration
      include RSpec::Core::Hooks

      # Module that holds `attr_reader` declarations. It's in a separate
      # module to allow us to override those methods and use `super`.
      # @private
      Readers = Module.new
      include Readers

      # @private
      class MustBeConfiguredBeforeExampleGroupsError < StandardError; end

      # @private
      def self.define_reader(name)
        Readers.class_eval do
          remove_method name if method_defined?(name)
          attr_reader name
        end

        define_method(name) { value_for(name) { super() } }
      end

      # @private
      def self.define_aliases(name, alias_name)
        alias_method alias_name, name
        alias_method "#{alias_name}=", "#{name}="
        define_predicate_for alias_name
      end

      # @private
      def self.define_predicate_for(*names)
        names.each { |name| alias_method "#{name}?", name }
      end

      # @private
      #
      # Invoked by the `add_setting` instance method. Use that method on a
      # `Configuration` instance rather than this class method.
      def self.add_setting(name, opts={})
        raise "Use the instance add_setting method if you want to set a default" if opts.key?(:default)
        attr_writer name
        add_read_only_setting name

        Array(opts[:alias_with]).each do |alias_name|
          define_aliases(name, alias_name)
        end
      end

      # @private
      #
      # As `add_setting` but only add the reader.
      def self.add_read_only_setting(name, opts={})
        raise "Use the instance add_setting method if you want to set a default" if opts.key?(:default)
        define_reader name
        define_predicate_for name
      end

      # @macro [attach] add_setting
      #   @!attribute [rw] $1
      #   @!method $1=(value)
      #
      # @macro [attach] define_reader
      #   @!attribute [r] $1

      # @macro add_setting
      # Path to use if no path is provided to the `rspec` command (default:
      # `"spec"`). Allows you to just type `rspec` instead of `rspec spec` to
      # run all the examples in the `spec` directory.
      #
      # @note Other scripts invoking `rspec` indirectly will ignore this
      #   setting.
      add_setting :default_path

      # @macro add_setting
      # Run examples over DRb (default: `false`). RSpec doesn't supply the DRb
      # server, but you can use tools like spork.
      add_setting :drb

      # @macro add_setting
      # The drb_port (default: nil).
      add_setting :drb_port

      # @macro add_setting
      # Default: `$stderr`.
      add_setting :error_stream

      # Indicates if the DSL has been exposed off of modules and `main`.
      # Default: true
      def expose_dsl_globally?
        Core::DSL.exposed_globally?
      end

      # Use this to expose the core RSpec DSL via `Module` and the `main`
      # object. It will be set automatically but you can override it to
      # remove the DSL.
      # Default: true
      def expose_dsl_globally=(value)
        if value
          Core::DSL.expose_globally!
          Core::SharedExampleGroup::TopLevelDSL.expose_globally!
        else
          Core::DSL.remove_globally!
          Core::SharedExampleGroup::TopLevelDSL.remove_globally!
        end
      end

      # Determines where deprecation warnings are printed.
      # Defaults to `$stderr`.
      # @return [IO, String] IO to write to or filename to write to
      define_reader :deprecation_stream

      # Determines where deprecation warnings are printed.
      # @param value [IO, String] IO to write to or filename to write to
      def deprecation_stream=(value)
        if @reporter && !value.equal?(@deprecation_stream)
          warn "RSpec's reporter has already been initialized with " \
            "#{deprecation_stream.inspect} as the deprecation stream, so your change to "\
            "`deprecation_stream` will be ignored. You should configure it earlier for " \
            "it to take effect, or use the `--deprecation-out` CLI option. " \
            "(Called from #{CallerFilter.first_non_rspec_line})"
        else
          @deprecation_stream = value
        end
      end

      # @macro define_reader
      # The file path to use for persisting example statuses. Necessary for the
      # `--only-failures` and `--next-failures` CLI options.
      #
      # @overload example_status_persistence_file_path
      #   @return [String] the file path
      # @overload example_status_persistence_file_path=(value)
      #   @param value [String] the file path
      define_reader :example_status_persistence_file_path

      # Sets the file path to use for persisting example statuses. Necessary for the
      # `--only-failures` and `--next-failures` CLI options.
      def example_status_persistence_file_path=(value)
        @example_status_persistence_file_path = value
        clear_values_derived_from_example_status_persistence_file_path
      end

      # @macro define_reader
      # Indicates if the `--only-failures` (or `--next-failure`) flag is being used.
      define_reader :only_failures
      alias_method :only_failures?, :only_failures

      # @private
      def only_failures_but_not_configured?
        only_failures? && !example_status_persistence_file_path
      end

      # @macro add_setting
      # Clean up and exit after the first failure (default: `false`).
      add_setting :fail_fast

      # @macro add_setting
      # Prints the formatter output of your suite without running any
      # examples or hooks.
      add_setting :dry_run

      # @macro add_setting
      # The exit code to return if there are any failures (default: 1).
      add_setting :failure_exit_code

      # @macro define_reader
      # Indicates files configured to be required.
      define_reader :requires

      # @macro define_reader
      # Returns dirs that have been prepended to the load path by the `-I`
      # command line option.
      define_reader :libs

      # @macro add_setting
      # Determines where RSpec will send its output.
      # Default: `$stdout`.
      define_reader :output_stream

      # Set the output stream for reporter.
      # @attr value [IO] value for output, defaults to $stdout
      def output_stream=(value)
        if @reporter && !value.equal?(@output_stream)
          warn "RSpec's reporter has already been initialized with " \
            "#{output_stream.inspect} as the output stream, so your change to "\
            "`output_stream` will be ignored. You should configure it earlier for " \
            "it to take effect. (Called from #{CallerFilter.first_non_rspec_line})"
        else
          @output_stream = value
        end
      end

      # @macro define_reader
      # Load files matching this pattern (default: `'**{,/*/**}/*_spec.rb'`).
      define_reader :pattern

      # Set pattern to match files to load.
      # @attr value [String] the filename pattern to filter spec files by
      def pattern=(value)
        update_pattern_attr :pattern, value
      end

      # @macro define_reader
      # Exclude files matching this pattern.
      define_reader :exclude_pattern

      # Set pattern to match files to exclude.
      # @attr value [String] the filename pattern to exclude spec files by
      def exclude_pattern=(value)
        update_pattern_attr :exclude_pattern, value
      end

      # @macro add_setting
      # Report the times for the slowest examples (default: `false`).
      # Use this to specify the number of examples to include in the profile.
      add_setting :profile_examples

      # @macro add_setting
      # Run all examples if none match the configured filters
      # (default: `false`).
      add_setting :run_all_when_everything_filtered

      # @macro add_setting
      # Color to use to indicate success.
      # @param color [Symbol] defaults to `:green` but can be set to one of the
      #   following: `[:black, :white, :red, :green, :yellow, :blue, :magenta,
      #   :cyan]`
      add_setting :success_color

      # @macro add_setting
      # Color to use to print pending examples.
      # @param color [Symbol] defaults to `:yellow` but can be set to one of the
      #   following: `[:black, :white, :red, :green, :yellow, :blue, :magenta,
      #   :cyan]`
      add_setting :pending_color

      # @macro add_setting
      # Color to use to indicate failure.
      # @param color [Symbol] defaults to `:red` but can be set to one of the
      #   following: `[:black, :white, :red, :green, :yellow, :blue, :magenta,
      #   :cyan]`
      add_setting :failure_color

      # @macro add_setting
      # The default output color.
      # @param color [Symbol] defaults to `:white` but can be set to one of the
      #   following: `[:black, :white, :red, :green, :yellow, :blue, :magenta,
      #   :cyan]`
      add_setting :default_color

      # @macro add_setting
      # Color used when a pending example is fixed.
      # @param color [Symbol] defaults to `:blue` but can be set to one of the
      #   following: `[:black, :white, :red, :green, :yellow, :blue, :magenta,
      #   :cyan]`
      add_setting :fixed_color

      # @macro add_setting
      # Color used to print details.
      # @param color [Symbol] defaults to `:cyan` but can be set to one of the
      #   following: `[:black, :white, :red, :green, :yellow, :blue, :magenta,
      #   :cyan]`
      add_setting :detail_color

      # Deprecated. This config option was added in RSpec 2 to pave the way
      # for this being the default behavior in RSpec 3. Now this option is
      # a no-op.
      def treat_symbols_as_metadata_keys_with_true_values=(_value)
        RSpec.deprecate(
          "RSpec::Core::Configuration#treat_symbols_as_metadata_keys_with_true_values=",
          :message => "RSpec::Core::Configuration#treat_symbols_as_metadata_keys_with_true_values= " \
                      "is deprecated, it is now set to true as default and " \
                      "setting it to false has no effect."
        )
      end

      # Record the start time of the spec suite to measure load time.
      add_setting :start_time

      # @macro add_setting
      # Use threadsafe options where available.
      # Currently this will place a mutex around memoized values such as let blocks.
      add_setting :threadsafe

      # @private
      add_setting :tty
      # @private
      attr_writer :files_to_run
      # @private
      attr_accessor :filter_manager
      # @private
      attr_accessor :static_config_filter_manager
      # @private
      attr_reader :backtrace_formatter, :ordering_manager, :loaded_spec_files

      def initialize
        # rubocop:disable Style/GlobalVars
        @start_time = $_rspec_core_load_started_at || ::RSpec::Core::Time.now
        # rubocop:enable Style/GlobalVars
        @expectation_frameworks = []
        @include_modules = FilterableItemRepository::QueryOptimized.new(:any?)
        @extend_modules  = FilterableItemRepository::QueryOptimized.new(:any?)
        @prepend_modules = FilterableItemRepository::QueryOptimized.new(:any?)

        @before_suite_hooks = []
        @after_suite_hooks  = []

        @mock_framework = nil
        @files_or_directories_to_run = []
        @loaded_spec_files = Set.new
        @color = false
        @pattern = '**{,/*/**}/*_spec.rb'
        @exclude_pattern = ''
        @failure_exit_code = 1
        @spec_files_loaded = false

        @backtrace_formatter = BacktraceFormatter.new

        @default_path = 'spec'
        @deprecation_stream = $stderr
        @output_stream = $stdout
        @reporter = nil
        @reporter_buffer = nil
        @filter_manager = FilterManager.new
        @static_config_filter_manager = FilterManager.new
        @ordering_manager = Ordering::ConfigurationManager.new
        @preferred_options = {}
        @failure_color = :red
        @success_color = :green
        @pending_color = :yellow
        @default_color = :white
        @fixed_color = :blue
        @detail_color = :cyan
        @profile_examples = false
        @requires = []
        @libs = []
        @derived_metadata_blocks = FilterableItemRepository::QueryOptimized.new(:any?)
        @threadsafe = true

        define_built_in_hooks
      end

      # @private
      #
      # Used to set higher priority option values from the command line.
      def force(hash)
        ordering_manager.force(hash)
        @preferred_options.merge!(hash)

        return unless hash.key?(:example_status_persistence_file_path)
        clear_values_derived_from_example_status_persistence_file_path
      end

      # @private
      def reset
        @spec_files_loaded = false
        @reporter = nil
        @formatter_loader = nil
      end

      # @private
      def reset_filters
        self.filter_manager = FilterManager.new
        filter_manager.include_only(
          Metadata.deep_hash_dup(static_config_filter_manager.inclusions.rules)
        )
        filter_manager.exclude_only(
          Metadata.deep_hash_dup(static_config_filter_manager.exclusions.rules)
        )
      end

      # @overload add_setting(name)
      # @overload add_setting(name, opts)
      # @option opts [Symbol] :default
      #
      #   Set a default value for the generated getter and predicate methods:
      #
      #       add_setting(:foo, :default => "default value")
      #
      # @option opts [Symbol] :alias_with
      #
      #   Use `:alias_with` to alias the setter, getter, and predicate to
      #   another name, or names:
      #
      #       add_setting(:foo, :alias_with => :bar)
      #       add_setting(:foo, :alias_with => [:bar, :baz])
      #
      # Adds a custom setting to the RSpec.configuration object.
      #
      #     RSpec.configuration.add_setting :foo
      #
      # Used internally and by extension frameworks like rspec-rails, so they
      # can add config settings that are domain specific. For example:
      #
      #     RSpec.configure do |c|
      #       c.add_setting :use_transactional_fixtures,
      #         :default => true,
      #         :alias_with => :use_transactional_examples
      #     end
      #
      # `add_setting` creates three methods on the configuration object, a
      # setter, a getter, and a predicate:
      #
      #     RSpec.configuration.foo=(value)
      #     RSpec.configuration.foo
      #     RSpec.configuration.foo? # Returns true if foo returns anything but nil or false.
      def add_setting(name, opts={})
        default = opts.delete(:default)
        (class << self; self; end).class_exec do
          add_setting(name, opts)
        end
        __send__("#{name}=", default) if default
      end

      # Returns the configured mock framework adapter module.
      def mock_framework
        if @mock_framework.nil?
          begin
            mock_with :rspec
          rescue LoadError
            mock_with :nothing
          end
        end
        @mock_framework
      end

      # Delegates to mock_framework=(framework).
      def mock_framework=(framework)
        mock_with framework
      end

      # Regexps used to exclude lines from backtraces.
      #
      # Excludes lines from ruby (and jruby) source, installed gems, anything
      # in any "bin" directory, and any of the RSpec libs (outside gem
      # installs) by default.
      #
      # You can modify the list via the getter, or replace it with the setter.
      #
      # To override this behaviour and display a full backtrace, use
      # `--backtrace` on the command line, in a `.rspec` file, or in the
      # `rspec_options` attribute of RSpec's rake task.
      def backtrace_exclusion_patterns
        @backtrace_formatter.exclusion_patterns
      end

      # Set regular expressions used to exclude lines in backtrace.
      # @param patterns [Regexp] set the backtrace exlusion pattern
      def backtrace_exclusion_patterns=(patterns)
        @backtrace_formatter.exclusion_patterns = patterns
      end

      # Regexps used to include lines in backtraces.
      #
      # Defaults to [Regexp.new Dir.getwd].
      #
      # Lines that match an exclusion _and_ an inclusion pattern
      # will be included.
      #
      # You can modify the list via the getter, or replace it with the setter.
      def backtrace_inclusion_patterns
        @backtrace_formatter.inclusion_patterns
      end

      # Set regular expressions used to include lines in backtrace.
      # @attr patterns [Regexp] set backtrace_formatter inclusion_patterns
      def backtrace_inclusion_patterns=(patterns)
        @backtrace_formatter.inclusion_patterns = patterns
      end

      # Adds {#backtrace_exclusion_patterns} that will filter lines from
      # the named gems from backtraces.
      #
      # @param gem_names [Array<String>] Names of the gems to filter
      #
      # @example
      #   RSpec.configure do |config|
      #     config.filter_gems_from_backtrace "rack", "rake"
      #   end
      #
      # @note The patterns this adds will match the named gems in their common
      #   locations (e.g. system gems, vendored with bundler, installed as a
      #   :git dependency with bundler, etc) but is not guaranteed to work for
      #   all possible gem locations. For example, if you have the gem source
      #   in a directory with a completely unrelated name, and use bundler's
      #   :path option, this will not filter it.
      def filter_gems_from_backtrace(*gem_names)
        gem_names.each do |name|
          @backtrace_formatter.filter_gem(name)
        end
      end

      # @private
      MOCKING_ADAPTERS = {
        :rspec    => :RSpec,
        :flexmock => :Flexmock,
        :rr       => :RR,
        :mocha    => :Mocha,
        :nothing  => :Null
      }

      # Sets the mock framework adapter module.
      #
      # `framework` can be a Symbol or a Module.
      #
      # Given any of `:rspec`, `:mocha`, `:flexmock`, or `:rr`, configures the
      # named framework.
      #
      # Given `:nothing`, configures no framework. Use this if you don't use
      # any mocking framework to save a little bit of overhead.
      #
      # Given a Module, includes that module in every example group. The module
      # should adhere to RSpec's mock framework adapter API:
      #
      #     setup_mocks_for_rspec
      #       - called before each example
      #
      #     verify_mocks_for_rspec
      #       - called after each example if the example hasn't yet failed.
      #         Framework should raise an exception when expectations fail
      #
      #     teardown_mocks_for_rspec
      #       - called after verify_mocks_for_rspec (even if there are errors)
      #
      # If the module responds to `configuration` and `mock_with` receives a
      # block, it will yield the configuration object to the block e.g.
      #
      #     config.mock_with OtherMockFrameworkAdapter do |mod_config|
      #       mod_config.custom_setting = true
      #     end
      def mock_with(framework)
        framework_module =
          if framework.is_a?(Module)
            framework
          else
            const_name = MOCKING_ADAPTERS.fetch(framework) do
              raise ArgumentError,
                    "Unknown mocking framework: #{framework.inspect}. " \
                    "Pass a module or one of #{MOCKING_ADAPTERS.keys.inspect}"
            end

            RSpec::Support.require_rspec_core "mocking_adapters/#{const_name.to_s.downcase}"
            RSpec::Core::MockingAdapters.const_get(const_name)
          end

        new_name, old_name = [framework_module, @mock_framework].map do |mod|
          mod.respond_to?(:framework_name) ?  mod.framework_name : :unnamed
        end

        unless new_name == old_name
          assert_no_example_groups_defined(:mock_framework)
        end

        if block_given?
          raise "#{framework_module} must respond to `configuration` so that " \
                "mock_with can yield it." unless framework_module.respond_to?(:configuration)
          yield framework_module.configuration
        end

        @mock_framework = framework_module
      end

      # Returns the configured expectation framework adapter module(s)
      def expectation_frameworks
        if @expectation_frameworks.empty?
          begin
            expect_with :rspec
          rescue LoadError
            expect_with Module.new
          end
        end
        @expectation_frameworks
      end

      # Delegates to expect_with(framework).
      def expectation_framework=(framework)
        expect_with(framework)
      end

      # Sets the expectation framework module(s) to be included in each example
      # group.
      #
      # `frameworks` can be `:rspec`, `:test_unit`, `:minitest`, a custom
      # module, or any combination thereof:
      #
      #     config.expect_with :rspec
      #     config.expect_with :test_unit
      #     config.expect_with :minitest
      #     config.expect_with :rspec, :minitest
      #     config.expect_with OtherExpectationFramework
      #
      # RSpec will translate `:rspec`, `:minitest`, and `:test_unit` into the
      # appropriate modules.
      #
      # ## Configuration
      #
      # If the module responds to `configuration`, `expect_with` will
      # yield the `configuration` object if given a block:
      #
      #     config.expect_with OtherExpectationFramework do |custom_config|
      #       custom_config.custom_setting = true
      #     end
      def expect_with(*frameworks)
        modules = frameworks.map do |framework|
          case framework
          when Module
            framework
          when :rspec
            require 'rspec/expectations'

            # Tag this exception class so our exception formatting logic knows
            # that it satisfies the `MultipleExceptionError` interface.
            ::RSpec::Expectations::MultipleExpectationsNotMetError.__send__(
              :include, MultipleExceptionError::InterfaceTag
            )

            ::RSpec::Matchers
          when :test_unit
            require 'rspec/core/test_unit_assertions_adapter'
            ::RSpec::Core::TestUnitAssertionsAdapter
          when :minitest
            require 'rspec/core/minitest_assertions_adapter'
            ::RSpec::Core::MinitestAssertionsAdapter
          else
            raise ArgumentError, "#{framework.inspect} is not supported"
          end
        end

        if (modules - @expectation_frameworks).any?
          assert_no_example_groups_defined(:expect_with)
        end

        if block_given?
          raise "expect_with only accepts a block with a single argument. " \
                "Call expect_with #{modules.length} times, " \
                "once with each argument, instead." if modules.length > 1
          raise "#{modules.first} must respond to `configuration` so that " \
                "expect_with can yield it." unless modules.first.respond_to?(:configuration)
          yield modules.first.configuration
        end

        @expectation_frameworks.push(*modules)
      end

      # Check if full backtrace is enabled.
      # @return [Boolean] is full backtrace enabled
      def full_backtrace?
        @backtrace_formatter.full_backtrace?
      end

      # Toggle full backtrace.
      # @attr true_or_false [Boolean] toggle full backtrace display
      def full_backtrace=(true_or_false)
        @backtrace_formatter.full_backtrace = true_or_false
      end

      # Returns the configuration option for color, but should not
      # be used to check if color is supported.
      #
      # @see color_enabled?
      # @return [Boolean]
      def color
        value_for(:color) { @color }
      end

      # Check if color is enabled for a particular output.
      # @param output [IO] an output stream to use, defaults to the current
      #        `output_stream`
      # @return [Boolean]
      def color_enabled?(output=output_stream)
        output_to_tty?(output) && color
      end

      # Toggle output color.
      # @attr true_or_false [Boolean] toggle color enabled
      def color=(true_or_false)
        return unless true_or_false

        if RSpec::Support::OS.windows? && !ENV['ANSICON']
          RSpec.warning "You must use ANSICON 1.31 or later " \
                        "(http://adoxa.3eeweb.com/ansicon/) to use colour " \
                        "on Windows"
          @color = false
        else
          @color = true
        end
      end

      # @private
      def libs=(libs)
        libs.map do |lib|
          @libs.unshift lib
          $LOAD_PATH.unshift lib
        end
      end

      # Run examples matching on `description` in all files to run.
      # @param description [String, Regexp] the pattern to filter on
      def full_description=(description)
        filter_run :full_description => Regexp.union(*Array(description).map { |d| Regexp.new(d) })
      end

      # @return [Array] full description filter
      def full_description
        filter.fetch :full_description, nil
      end

      # @overload add_formatter(formatter)
      #
      # Adds a formatter to the formatters collection. `formatter` can be a
      # string representing any of the built-in formatters (see
      # `built_in_formatter`), or a custom formatter class.
      #
      # ### Note
      #
      # For internal purposes, `add_formatter` also accepts the name of a class
      # and paths to use for output streams, but you should consider that a
      # private api that may change at any time without notice.
      def add_formatter(formatter_to_use, *paths)
        paths << output_stream if paths.empty?
        formatter_loader.add formatter_to_use, *paths
      end
      alias_method :formatter=, :add_formatter

      # The formatter that will be used if no formatter has been set.
      # Defaults to 'progress'.
      def default_formatter
        formatter_loader.default_formatter
      end

      # Sets a fallback formatter to use if none other has been set.
      #
      # @example
      #
      #   RSpec.configure do |rspec|
      #     rspec.default_formatter = 'doc'
      #   end
      def default_formatter=(value)
        formatter_loader.default_formatter = value
      end

      # Returns a duplicate of the formatters currently loaded in
      # the `FormatterLoader` for introspection.
      #
      # Note as this is a duplicate, any mutations will be disregarded.
      #
      # @return [Array] the formatters currently loaded
      def formatters
        formatter_loader.formatters.dup
      end

      # @private
      def formatter_loader
        @formatter_loader ||= Formatters::Loader.new(Reporter.new(self))
      end

      # @private
      #
      # This buffer is used to capture all messages sent to the reporter during
      # reporter initialization. It can then replay those messages after the
      # formatter is correctly initialized. Otherwise, deprecation warnings
      # during formatter initialization can cause an infinite loop.
      class DeprecationReporterBuffer
        def initialize
          @calls = []
        end

        def deprecation(*args)
          @calls << args
        end

        def play_onto(reporter)
          @calls.each do |args|
            reporter.deprecation(*args)
          end
        end
      end

      # @private
      def reporter
        # @reporter_buffer should only ever be set in this method to cover
        # initialization of @reporter.
        @reporter_buffer || @reporter ||=
          begin
            @reporter_buffer = DeprecationReporterBuffer.new
            formatter_loader.setup_default output_stream, deprecation_stream
            @reporter_buffer.play_onto(formatter_loader.reporter)
            @reporter_buffer = nil
            formatter_loader.reporter
          end
      end

      # @api private
      #
      # Defaults `profile_examples` to 10 examples when `@profile_examples` is
      # `true`.
      def profile_examples
        profile = value_for(:profile_examples) { @profile_examples }
        if profile && !profile.is_a?(Integer)
          10
        else
          profile
        end
      end

      # @private
      def files_or_directories_to_run=(*files)
        files = files.flatten

        if (command == 'rspec' || Runner.running_in_drb?) && default_path && files.empty?
          files << default_path
        end

        @files_or_directories_to_run = files
        @files_to_run = nil
      end

      # The spec files RSpec will run.
      # @return [Array] specified files about to run
      def files_to_run
        @files_to_run ||= get_files_to_run(@files_or_directories_to_run)
      end

      # @private
      def last_run_statuses
        @last_run_statuses ||= Hash.new(UNKNOWN_STATUS).tap do |statuses|
          if (path = example_status_persistence_file_path)
            begin
              ExampleStatusPersister.load_from(path).inject(statuses) do |hash, example|
                hash[example.fetch(:example_id)] = example.fetch(:status)
                hash
              end
            rescue SystemCallError => e
              RSpec.warning "Could not read from #{path.inspect} (configured as " \
                            "`config.example_status_persistence_file_path`) due " \
                            "to a system error: #{e.inspect}. Please check that " \
                            "the config option is set to an accessible, valid " \
                            "file path", :call_site => nil
            end
          end
        end
      end

      # @private
      UNKNOWN_STATUS = "unknown".freeze

      # @private
      FAILED_STATUS = "failed".freeze

      # @private
      def spec_files_with_failures
        @spec_files_with_failures ||= last_run_statuses.inject(Set.new) do |files, (id, status)|
          files << id.split(ON_SQUARE_BRACKETS).first if status == FAILED_STATUS
          files
        end.to_a
      end

      # Creates a method that delegates to `example` including the submitted
      # `args`. Used internally to add variants of `example` like `pending`:
      # @param name [String] example name alias
      # @param args [Array<Symbol>, Hash] metadata for the generated example
      #
      # @note The specific example alias below (`pending`) is already
      #   defined for you.
      # @note Use with caution. This extends the language used in your
      #   specs, but does not add any additional documentation. We use this
      #   in RSpec to define methods like `focus` and `xit`, but we also add
      #   docs for those methods.
      #
      # @example
      #   RSpec.configure do |config|
      #     config.alias_example_to :pending, :pending => true
      #   end
      #
      #   # This lets you do this:
      #
      #   describe Thing do
      #     pending "does something" do
      #       thing = Thing.new
      #     end
      #   end
      #
      #   # ... which is the equivalent of
      #
      #   describe Thing do
      #     it "does something", :pending => true do
      #       thing = Thing.new
      #     end
      #   end
      def alias_example_to(name, *args)
        extra_options = Metadata.build_hash_from(args)
        RSpec::Core::ExampleGroup.define_example_method(name, extra_options)
      end

      # Creates a method that defines an example group with the provided
      # metadata. Can be used to define example group/metadata shortcuts.
      #
      # @example
      #   RSpec.configure do |config|
      #     config.alias_example_group_to :describe_model, :type => :model
      #   end
      #
      #   shared_context_for "model tests", :type => :model do
      #     # define common model test helper methods, `let` declarations, etc
      #   end
      #
      #   # This lets you do this:
      #
      #   RSpec.describe_model User do
      #   end
      #
      #   # ... which is the equivalent of
      #
      #   RSpec.describe User, :type => :model do
      #   end
      #
      # @note The defined aliased will also be added to the top level
      #       (e.g. `main` and from within modules) if
      #       `expose_dsl_globally` is set to true.
      # @see #alias_example_to
      # @see #expose_dsl_globally=
      def alias_example_group_to(new_name, *args)
        extra_options = Metadata.build_hash_from(args)
        RSpec::Core::ExampleGroup.define_example_group_method(new_name, extra_options)
      end

      # Define an alias for it_should_behave_like that allows different
      # language (like "it_has_behavior" or "it_behaves_like") to be
      # employed when including shared examples.
      #
      # @example
      #   RSpec.configure do |config|
      #     config.alias_it_behaves_like_to(:it_has_behavior, 'has behavior:')
      #   end
      #
      #   # allows the user to include a shared example group like:
      #
      #   describe Entity do
      #     it_has_behavior 'sortability' do
      #       let(:sortable) { Entity.new }
      #     end
      #   end
      #
      #   # which is reported in the output as:
      #   # Entity
      #   #   has behavior: sortability
      #   #     ...sortability examples here
      #
      # @note Use with caution. This extends the language used in your
      #   specs, but does not add any additional documentation. We use this
      #   in RSpec to define `it_should_behave_like` (for backward
      #   compatibility), but we also add docs for that method.
      def alias_it_behaves_like_to(new_name, report_label='')
        RSpec::Core::ExampleGroup.define_nested_shared_group_method(new_name, report_label)
      end
      alias_method :alias_it_should_behave_like_to, :alias_it_behaves_like_to

      # Adds key/value pairs to the `inclusion_filter`. If `args`
      # includes any symbols that are not part of the hash, each symbol
      # is treated as a key in the hash with the value `true`.
      #
      # ### Note
      #
      # Filters set using this method can be overridden from the command line
      # or config files (e.g. `.rspec`).
      #
      # @example
      #     # Given this declaration.
      #     describe "something", :foo => 'bar' do
      #       # ...
      #     end
      #
      #     # Any of the following will include that group.
      #     config.filter_run_including :foo => 'bar'
      #     config.filter_run_including :foo => /^ba/
      #     config.filter_run_including :foo => lambda {|v| v == 'bar'}
      #     config.filter_run_including :foo => lambda {|v,m| m[:foo] == 'bar'}
      #
      #     # Given a proc with an arity of 1, the lambda is passed the value
      #     # related to the key, e.g.
      #     config.filter_run_including :foo => lambda {|v| v == 'bar'}
      #
      #     # Given a proc with an arity of 2, the lambda is passed the value
      #     # related to the key, and the metadata itself e.g.
      #     config.filter_run_including :foo => lambda {|v,m| m[:foo] == 'bar'}
      #
      #     filter_run_including :foo # same as filter_run_including :foo => true
      def filter_run_including(*args)
        meta = Metadata.build_hash_from(args, :warn_about_example_group_filtering)
        filter_manager.include_with_low_priority meta
        static_config_filter_manager.include_with_low_priority Metadata.deep_hash_dup(meta)
      end

      alias_method :filter_run, :filter_run_including

      # Clears and reassigns the `inclusion_filter`. Set to `nil` if you don't
      # want any inclusion filter at all.
      #
      # ### Warning
      #
      # This overrides any inclusion filters/tags set on the command line or in
      # configuration files.
      def inclusion_filter=(filter)
        meta = Metadata.build_hash_from([filter], :warn_about_example_group_filtering)
        filter_manager.include_only meta
      end

      alias_method :filter=, :inclusion_filter=

      # Returns the `inclusion_filter`. If none has been set, returns an empty
      # hash.
      def inclusion_filter
        filter_manager.inclusions
      end

      alias_method :filter, :inclusion_filter

      # Adds key/value pairs to the `exclusion_filter`. If `args`
      # includes any symbols that are not part of the hash, each symbol
      # is treated as a key in the hash with the value `true`.
      #
      # ### Note
      #
      # Filters set using this method can be overridden from the command line
      # or config files (e.g. `.rspec`).
      #
      # @example
      #     # Given this declaration.
      #     describe "something", :foo => 'bar' do
      #       # ...
      #     end
      #
      #     # Any of the following will exclude that group.
      #     config.filter_run_excluding :foo => 'bar'
      #     config.filter_run_excluding :foo => /^ba/
      #     config.filter_run_excluding :foo => lambda {|v| v == 'bar'}
      #     config.filter_run_excluding :foo => lambda {|v,m| m[:foo] == 'bar'}
      #
      #     # Given a proc with an arity of 1, the lambda is passed the value
      #     # related to the key, e.g.
      #     config.filter_run_excluding :foo => lambda {|v| v == 'bar'}
      #
      #     # Given a proc with an arity of 2, the lambda is passed the value
      #     # related to the key, and the metadata itself e.g.
      #     config.filter_run_excluding :foo => lambda {|v,m| m[:foo] == 'bar'}
      #
      #     filter_run_excluding :foo # same as filter_run_excluding :foo => true
      def filter_run_excluding(*args)
        meta = Metadata.build_hash_from(args, :warn_about_example_group_filtering)
        filter_manager.exclude_with_low_priority meta
        static_config_filter_manager.exclude_with_low_priority Metadata.deep_hash_dup(meta)
      end

      # Clears and reassigns the `exclusion_filter`. Set to `nil` if you don't
      # want any exclusion filter at all.
      #
      # ### Warning
      #
      # This overrides any exclusion filters/tags set on the command line or in
      # configuration files.
      def exclusion_filter=(filter)
        meta = Metadata.build_hash_from([filter], :warn_about_example_group_filtering)
        filter_manager.exclude_only meta
      end

      # Returns the `exclusion_filter`. If none has been set, returns an empty
      # hash.
      def exclusion_filter
        filter_manager.exclusions
      end

      # Tells RSpec to include `mod` in example groups. Methods defined in
      # `mod` are exposed to examples (not example groups). Use `filters` to
      # constrain the groups or examples in which to include the module.
      #
      # @example
      #
      #     module AuthenticationHelpers
      #       def login_as(user)
      #         # ...
      #       end
      #     end
      #
      #     module UserHelpers
      #       def users(username)
      #         # ...
      #       end
      #     end
      #
      #     RSpec.configure do |config|
      #       config.include(UserHelpers) # included in all modules
      #       config.include(AuthenticationHelpers, :type => :request)
      #     end
      #
      #     describe "edit profile", :type => :request do
      #       it "can be viewed by owning user" do
      #         login_as users(:jdoe)
      #         get "/profiles/jdoe"
      #         assert_select ".username", :text => 'jdoe'
      #       end
      #     end
      #
      # @note Filtered module inclusions can also be applied to
      #   individual examples that have matching metadata. Just like
      #   Ruby's object model is that every object has a singleton class
      #   which has only a single instance, RSpec's model is that every
      #   example has a singleton example group containing just the one
      #   example.
      #
      # @see #extend
      # @see #prepend
      def include(mod, *filters)
        meta = Metadata.build_hash_from(filters, :warn_about_example_group_filtering)
        @include_modules.append(mod, meta)
        configure_existing_groups(mod, meta, :safe_include)
      end

      # Tells RSpec to extend example groups with `mod`. Methods defined in
      # `mod` are exposed to example groups (not examples). Use `filters` to
      # constrain the groups to extend.
      #
      # Similar to `include`, but behavior is added to example groups, which
      # are classes, rather than the examples, which are instances of those
      # classes.
      #
      # @example
      #
      #     module UiHelpers
      #       def run_in_browser
      #         # ...
      #       end
      #     end
      #
      #     RSpec.configure do |config|
      #       config.extend(UiHelpers, :type => :request)
      #     end
      #
      #     describe "edit profile", :type => :request do
      #       run_in_browser
      #
      #       it "does stuff in the client" do
      #         # ...
      #       end
      #     end
      #
      # @see #include
      # @see #prepend
      def extend(mod, *filters)
        meta = Metadata.build_hash_from(filters, :warn_about_example_group_filtering)
        @extend_modules.append(mod, meta)
        configure_existing_groups(mod, meta, :safe_extend)
      end

      if RSpec::Support::RubyFeatures.module_prepends_supported?
        # Tells RSpec to prepend example groups with `mod`. Methods defined in
        # `mod` are exposed to examples (not example groups). Use `filters` to
        # constrain the groups in which to prepend the module.
        #
        # Similar to `include`, but module is included before the example group's class
        # in the ancestor chain.
        #
        # @example
        #
        #     module OverrideMod
        #       def override_me
        #         "overridden"
        #       end
        #     end
        #
        #     RSpec.configure do |config|
        #       config.prepend(OverrideMod, :method => :prepend)
        #     end
        #
        #     describe "overriding example's class", :method => :prepend do
        #       it "finds the user" do
        #         self.class.class_eval do
        #           def override_me
        #           end
        #         end
        #         override_me # => "overridden"
        #         # ...
        #       end
        #     end
        #
        # @see #include
        # @see #extend
        def prepend(mod, *filters)
          meta = Metadata.build_hash_from(filters, :warn_about_example_group_filtering)
          @prepend_modules.append(mod, meta)
          configure_existing_groups(mod, meta, :safe_prepend)
        end
      end

      # @private
      #
      # Used internally to extend a group with modules using `include`, `prepend` and/or
      # `extend`.
      def configure_group(group)
        configure_group_with group, @include_modules, :safe_include
        configure_group_with group, @extend_modules,  :safe_extend
        configure_group_with group, @prepend_modules, :safe_prepend
      end

      # @private
      def configure_group_with(group, module_list, application_method)
        module_list.items_for(group.metadata).each do |mod|
          __send__(application_method, mod, group)
        end
      end

      # @private
      def configure_existing_groups(mod, meta, application_method)
        RSpec.world.all_example_groups.each do |group|
          next unless meta.empty? || MetadataFilter.apply?(:any?, meta, group.metadata)
          __send__(application_method, mod, group)
        end
      end

      # @private
      #
      # Used internally to extend the singleton class of a single example's
      # example group instance with modules using `include` and/or `extend`.
      def configure_example(example)
        singleton_group = example.example_group_instance.singleton_class

        # We replace the metadata so that SharedExampleGroupModule#included
        # has access to the example's metadata[:location].
        singleton_group.with_replaced_metadata(example.metadata) do
          modules = @include_modules.items_for(example.metadata)
          modules.each do |mod|
            safe_include(mod, example.example_group_instance.singleton_class)
          end

          MemoizedHelpers.define_helpers_on(singleton_group) unless modules.empty?
        end
      end

      if RSpec::Support::RubyFeatures.module_prepends_supported?
        # @private
        def safe_prepend(mod, host)
          host.__send__(:prepend, mod) unless host < mod
        end
      end

      # @private
      def requires=(paths)
        directories = ['lib', default_path].select { |p| File.directory? p }
        RSpec::Core::RubyProject.add_to_load_path(*directories)
        paths.each { |path| require path }
        @requires += paths
      end

      # @private
      if RUBY_VERSION.to_f >= 1.9
        # @private
        def safe_include(mod, host)
          host.__send__(:include, mod) unless host < mod
        end

        # @private
        def safe_extend(mod, host)
          host.extend(mod) unless host.singleton_class < mod
        end
      else # for 1.8.7
        # :nocov:
        # @private
        def safe_include(mod, host)
          host.__send__(:include, mod) unless host.included_modules.include?(mod)
        end

        # @private
        def safe_extend(mod, host)
          host.extend(mod) unless (class << host; self; end).included_modules.include?(mod)
        end
        # :nocov:
      end

      # @private
      def configure_mock_framework
        RSpec::Core::ExampleGroup.__send__(:include, mock_framework)
        conditionally_disable_mocks_monkey_patching
      end

      # @private
      def configure_expectation_framework
        expectation_frameworks.each do |framework|
          RSpec::Core::ExampleGroup.__send__(:include, framework)
        end
        conditionally_disable_expectations_monkey_patching
      end

      # @private
      def load_spec_files
        files_to_run.uniq.each do |f|
          file = File.expand_path(f)
          load file
          loaded_spec_files << file
        end

        @spec_files_loaded = true
      end

      # @private
      DEFAULT_FORMATTER = lambda { |string| string }

      # Formats the docstring output using the block provided.
      #
      # @example
      #   # This will strip the descriptions of both examples and example
      #   # groups.
      #   RSpec.configure do |config|
      #     config.format_docstrings { |s| s.strip }
      #   end
      def format_docstrings(&block)
        @format_docstrings_block = block_given? ? block : DEFAULT_FORMATTER
      end

      # @private
      def format_docstrings_block
        @format_docstrings_block ||= DEFAULT_FORMATTER
      end

      # @private
      # @macro [attach] delegate_to_ordering_manager
      #   @!method $1
      def self.delegate_to_ordering_manager(*methods)
        methods.each do |method|
          define_method method do |*args, &block|
            ordering_manager.__send__(method, *args, &block)
          end
        end
      end

      # @macro delegate_to_ordering_manager
      #
      # Sets the seed value and sets the default global ordering to random.
      delegate_to_ordering_manager :seed=

      # @macro delegate_to_ordering_manager
      # Seed for random ordering (default: generated randomly each run).
      #
      # When you run specs with `--order random`, RSpec generates a random seed
      # for the randomization and prints it to the `output_stream` (assuming
      # you're using RSpec's built-in formatters). If you discover an ordering
      # dependency (i.e. examples fail intermittently depending on order), set
      # this (on Configuration or on the command line with `--seed`) to run
      # using the same seed while you debug the issue.
      #
      # We recommend, actually, that you use the command line approach so you
      # don't accidentally leave the seed encoded.
      delegate_to_ordering_manager :seed

      # @macro delegate_to_ordering_manager
      #
      # Sets the default global order and, if order is `'rand:<seed>'`, also
      # sets the seed.
      delegate_to_ordering_manager :order=

      # @macro delegate_to_ordering_manager
      # Registers a named ordering strategy that can later be
      # used to order an example group's subgroups by adding
      # `:order => <name>` metadata to the example group.
      #
      # @param name [Symbol] The name of the ordering.
      # @yield Block that will order the given examples or example groups
      # @yieldparam list [Array<RSpec::Core::Example>,
      #   Array<RSpec::Core::ExampleGroup>] The examples or groups to order
      # @yieldreturn [Array<RSpec::Core::Example>,
      #   Array<RSpec::Core::ExampleGroup>] The re-ordered examples or groups
      #
      # @example
      #   RSpec.configure do |rspec|
      #     rspec.register_ordering :reverse do |list|
      #       list.reverse
      #     end
      #   end
      #
      #   describe MyClass, :order => :reverse do
      #     # ...
      #   end
      #
      # @note Pass the symbol `:global` to set the ordering strategy that
      #   will be used to order the top-level example groups and any example
      #   groups that do not have declared `:order` metadata.
      delegate_to_ordering_manager :register_ordering

      # @private
      delegate_to_ordering_manager :seed_used?, :ordering_registry

      # Set Ruby warnings on or off.
      def warnings=(value)
        $VERBOSE = !!value
      end

      # @return [Boolean] Whether or not ruby warnings are enabled.
      def warnings?
        $VERBOSE
      end

      # Exposes the current running example via the named
      # helper method. RSpec 2.x exposed this via `example`,
      # but in RSpec 3.0, the example is instead exposed via
      # an arg yielded to `it`, `before`, `let`, etc. However,
      # some extension gems (such as Capybara) depend on the
      # RSpec 2.x's `example` method, so this config option
      # can be used to maintain compatibility.
      #
      # @param method_name [Symbol] the name of the helper method
      #
      # @example
      #
      #   RSpec.configure do |rspec|
      #     rspec.expose_current_running_example_as :example
      #   end
      #
      #   describe MyClass do
      #     before do
      #       # `example` can be used here because of the above config.
      #       do_something if example.metadata[:type] == "foo"
      #     end
      #   end
      def expose_current_running_example_as(method_name)
        ExposeCurrentExample.module_exec do
          extend RSpec::SharedContext
          let(method_name) { |ex| ex }
        end

        include ExposeCurrentExample
      end

      # @private
      module ExposeCurrentExample; end

      # Turns deprecation warnings into errors, in order to surface
      # the full backtrace of the call site. This can be useful when
      # you need more context to address a deprecation than the
      # single-line call site normally provided.
      #
      # @example
      #
      #   RSpec.configure do |rspec|
      #     rspec.raise_errors_for_deprecations!
      #   end
      def raise_errors_for_deprecations!
        self.deprecation_stream = Formatters::DeprecationFormatter::RaiseErrorStream.new
      end

      # Enables zero monkey patching mode for RSpec. It removes monkey
      # patching of the top-level DSL methods (`describe`,
      # `shared_examples_for`, etc) onto `main` and `Module`, instead
      # requiring you to prefix these methods with `RSpec.`. It enables
      # expect-only syntax for rspec-mocks and rspec-expectations. It
      # simply disables monkey patching on whatever pieces of RSpec
      # the user is using.
      #
      # @note It configures rspec-mocks and rspec-expectations only
      #   if the user is using those (either explicitly or implicitly
      #   by not setting `mock_with` or `expect_with` to anything else).
      #
      # @note If the user uses this options with `mock_with :mocha`
      #   (or similiar) they will still have monkey patching active
      #   in their test environment from mocha.
      #
      # @example
      #
      #   # It disables all monkey patching.
      #   RSpec.configure do |config|
      #     config.disable_monkey_patching!
      #   end
      #
      #   # Is an equivalent to
      #   RSpec.configure do |config|
      #     config.expose_dsl_globally = false
      #
      #     config.mock_with :rspec do |mocks|
      #       mocks.syntax = :expect
      #       mocks.patch_marshal_to_support_partial_doubles = false
      #     end
      #
      #     config.mock_with :rspec do |expectations|
      #       expectations.syntax = :expect
      #     end
      #   end
      def disable_monkey_patching!
        self.expose_dsl_globally = false
        self.disable_monkey_patching = true
        conditionally_disable_mocks_monkey_patching
        conditionally_disable_expectations_monkey_patching
      end

      # @private
      attr_accessor :disable_monkey_patching

      # Defines a callback that can assign derived metadata values.
      #
      # @param filters [Array<Symbol>, Hash] metadata filters that determine
      #   which example or group metadata hashes the callback will be triggered
      #   for. If none are given, the callback will be run against the metadata
      #   hashes of all groups and examples.
      # @yieldparam metadata [Hash] original metadata hash from an example or
      #   group. Mutate this in your block as needed.
      #
      # @example
      #   RSpec.configure do |config|
      #     # Tag all groups and examples in the spec/unit directory with
      #     # :type => :unit
      #     config.define_derived_metadata(:file_path => %r{/spec/unit/}) do |metadata|
      #       metadata[:type] = :unit
      #     end
      #   end
      def define_derived_metadata(*filters, &block)
        meta = Metadata.build_hash_from(filters, :warn_about_example_group_filtering)
        @derived_metadata_blocks.append(block, meta)
      end

      # @private
      def apply_derived_metadata_to(metadata)
        @derived_metadata_blocks.items_for(metadata).each do |block|
          block.call(metadata)
        end
      end

      # Defines a `before` hook. See {Hooks#before} for full docs.
      #
      # This method differs from {Hooks#before} in only one way: it supports
      # the `:suite` scope. Hooks with the `:suite` scope will be run once before
      # the first example of the entire suite is executed.
      #
      # @see #prepend_before
      # @see #after
      # @see #append_after
      def before(*args, &block)
        handle_suite_hook(args, @before_suite_hooks, :push,
                          Hooks::BeforeHook, block) || super(*args, &block)
      end
      alias_method :append_before, :before

      # Adds `block` to the start of the list of `before` blocks in the same
      # scope (`:example`, `:context`, or `:suite`), in contrast to {#before},
      # which adds the hook to the end of the list.
      #
      # See {Hooks#before} for full `before` hook docs.
      #
      # This method differs from {Hooks#prepend_before} in only one way: it supports
      # the `:suite` scope. Hooks with the `:suite` scope will be run once before
      # the first example of the entire suite is executed.
      #
      # @see #before
      # @see #after
      # @see #append_after
      def prepend_before(*args, &block)
        handle_suite_hook(args, @before_suite_hooks, :unshift,
                          Hooks::BeforeHook, block) || super(*args, &block)
      end

      # Defines a `after` hook. See {Hooks#after} for full docs.
      #
      # This method differs from {Hooks#after} in only one way: it supports
      # the `:suite` scope. Hooks with the `:suite` scope will be run once after
      # the last example of the entire suite is executed.
      #
      # @see #append_after
      # @see #before
      # @see #prepend_before
      def after(*args, &block)
        handle_suite_hook(args, @after_suite_hooks, :unshift,
                          Hooks::AfterHook, block) || super(*args, &block)
      end
      alias_method :prepend_after, :after

      # Adds `block` to the end of the list of `after` blocks in the same
      # scope (`:example`, `:context`, or `:suite`), in contrast to {#after},
      # which adds the hook to the start of the list.
      #
      # See {Hooks#after} for full `after` hook docs.
      #
      # This method differs from {Hooks#append_after} in only one way: it supports
      # the `:suite` scope. Hooks with the `:suite` scope will be run once after
      # the last example of the entire suite is executed.
      #
      # @see #append_after
      # @see #before
      # @see #prepend_before
      def append_after(*args, &block)
        handle_suite_hook(args, @after_suite_hooks, :push,
                          Hooks::AfterHook, block) || super(*args, &block)
      end

      # @private
      def with_suite_hooks
        return yield if dry_run?

        hook_context = SuiteHookContext.new
        begin
          run_hooks_with(@before_suite_hooks, hook_context)
          yield
        ensure
          run_hooks_with(@after_suite_hooks, hook_context)
        end
      end

      # @private
      # Holds the various registered hooks. Here we use a FilterableItemRepository
      # implementation that is specifically optimized for the read/write patterns
      # of the config object.
      def hooks
        @hooks ||= HookCollections.new(self, FilterableItemRepository::QueryOptimized)
      end

    private

      def handle_suite_hook(args, collection, append_or_prepend, hook_type, block)
        scope, meta = *args
        return nil unless scope == :suite

        if meta
          # TODO: in RSpec 4, consider raising an error here.
          # We warn only for backwards compatibility.
          RSpec.warn_with "WARNING: `:suite` hooks do not support metadata since " \
                          "they apply to the suite as a whole rather than " \
                          "any individual example or example group that has metadata. " \
                          "The metadata you have provided (#{meta.inspect}) will be ignored."
        end

        collection.__send__(append_or_prepend, hook_type.new(block, {}))
      end

      def run_hooks_with(hooks, hook_context)
        hooks.each { |h| h.run(hook_context) }
      end

      def get_files_to_run(paths)
        files = FlatMap.flat_map(paths_to_check(paths)) do |path|
          path = path.gsub(File::ALT_SEPARATOR, File::SEPARATOR) if File::ALT_SEPARATOR
          File.directory?(path) ? gather_directories(path) : extract_location(path)
        end.sort.uniq

        return files unless only_failures?
        relative_files = files.map { |f| Metadata.relative_path(File.expand_path f) }
        intersection = (relative_files & spec_files_with_failures.to_a)
        intersection.empty? ? files : intersection
      end

      def paths_to_check(paths)
        return paths if pattern_might_load_specs_from_vendored_dirs?
        paths + [Dir.getwd]
      end

      def pattern_might_load_specs_from_vendored_dirs?
        pattern.split(File::SEPARATOR).first.include?('**')
      end

      def gather_directories(path)
        include_files = get_matching_files(path, pattern)
        exclude_files = get_matching_files(path, exclude_pattern)
        (include_files - exclude_files).sort.uniq
      end

      def get_matching_files(path, pattern)
        Dir[file_glob_from(path, pattern)].map { |file| File.expand_path(file) }
      end

      def file_glob_from(path, pattern)
        stripped = "{#{pattern.gsub(/\s*,\s*/, ',')}}"
        return stripped if pattern =~ /^(\.\/)?#{Regexp.escape path}/ || absolute_pattern?(pattern)
        File.join(path, stripped)
      end

      if RSpec::Support::OS.windows?
        # :nocov:
        def absolute_pattern?(pattern)
          pattern =~ /\A[A-Z]:\\/ || windows_absolute_network_path?(pattern)
        end

        def windows_absolute_network_path?(pattern)
          return false unless ::File::ALT_SEPARATOR
          pattern.start_with?(::File::ALT_SEPARATOR + ::File::ALT_SEPARATOR)
        end
        # :nocov:
      else
        def absolute_pattern?(pattern)
          pattern.start_with?(File::Separator)
        end
      end

      # @private
      ON_SQUARE_BRACKETS = /[\[\]]/

      def extract_location(path)
        match = /^(.*?)((?:\:\d+)+)$/.match(path)

        if match
          captures = match.captures
          path, lines = captures[0], captures[1][1..-1].split(":").map { |n| n.to_i }
          filter_manager.add_location path, lines
        else
          path, scoped_ids = path.split(ON_SQUARE_BRACKETS)
          filter_manager.add_ids(path, scoped_ids.split(/\s*,\s*/)) if scoped_ids
        end

        return [] if path == default_path
        path
      end

      def command
        $0.split(File::SEPARATOR).last
      end

      def value_for(key)
        @preferred_options.fetch(key) { yield }
      end

      def define_built_in_hooks
        around(:example, :aggregate_failures => true) do |procsy|
          begin
            aggregate_failures(nil, :hide_backtrace => true, &procsy)
          rescue Exception => exception
            procsy.example.set_aggregate_failures_exception(exception)
          end
        end
      end

      def assert_no_example_groups_defined(config_option)
        return unless RSpec.world.example_groups.any?

        raise MustBeConfiguredBeforeExampleGroupsError.new(
          "RSpec's #{config_option} configuration option must be configured before " \
          "any example groups are defined, but you have already defined a group."
        )
      end

      def output_to_tty?(output=output_stream)
        tty? || (output.respond_to?(:tty?) && output.tty?)
      end

      def conditionally_disable_mocks_monkey_patching
        return unless disable_monkey_patching && rspec_mocks_loaded?

        RSpec::Mocks.configuration.tap do |config|
          config.syntax = :expect
          config.patch_marshal_to_support_partial_doubles = false
        end
      end

      def conditionally_disable_expectations_monkey_patching
        return unless disable_monkey_patching && rspec_expectations_loaded?

        RSpec::Expectations.configuration.syntax = :expect
      end

      def rspec_mocks_loaded?
        defined?(RSpec::Mocks.configuration)
      end

      def rspec_expectations_loaded?
        defined?(RSpec::Expectations.configuration)
      end

      def update_pattern_attr(name, value)
        if @spec_files_loaded
          RSpec.warning "Configuring `#{name}` to #{value} has no effect since " \
                        "RSpec has already loaded the spec files."
        end

        instance_variable_set(:"@#{name}", value)
        @files_to_run = nil
      end

      def clear_values_derived_from_example_status_persistence_file_path
        @last_run_statuses = nil
        @spec_files_with_failures = nil
      end
    end
    # rubocop:enable Style/ClassLength
  end
end
