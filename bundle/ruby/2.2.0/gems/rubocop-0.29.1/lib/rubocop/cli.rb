# encoding: utf-8

module RuboCop
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    attr_reader :options, :config_store

    def initialize
      @options = {}
      @config_store = ConfigStore.new
    end

    # Entry point for the application logic. Here we
    # do the command line arguments processing and inspect
    # the target files
    # @return [Fixnum] UNIX exit code
    def run(args = ARGV)
      @options, paths = Options.new.parse(args)
      act_on_options

      runner = Runner.new(@options, @config_store)
      trap_interrupt(runner)
      all_passed = runner.run(paths)
      display_error_summary(runner.errors)

      all_passed && !runner.aborting? && runner.errors.empty? ? 0 : 1
    rescue Cop::AmbiguousCopName => e
      $stderr.puts "Ambiguous cop name #{e.message} needs namespace " \
                   'qualifier.'
      return 1
    rescue StandardError, SyntaxError => e
      $stderr.puts e.message
      $stderr.puts e.backtrace
      return 1
    end

    def trap_interrupt(runner)
      Signal.trap('INT') do
        exit!(1) if runner.aborting?
        runner.abort
        $stderr.puts
        $stderr.puts 'Exiting... Interrupt again to exit immediately.'
      end
    end

    private

    def act_on_options
      handle_exiting_options

      ConfigLoader.debug = @options[:debug]
      ConfigLoader.auto_gen_config = @options[:auto_gen_config]

      @config_store.options_config = @options[:config] if @options[:config]

      Rainbow.enabled = false unless @options[:color]
    end

    def handle_exiting_options
      return unless Options::EXITING_OPTIONS.any? { |o| @options.key? o }

      puts RuboCop::Version.version(false) if @options[:version]
      puts RuboCop::Version.version(true) if @options[:verbose_version]
      print_available_cops if @options[:show_cops]
      exit(0)
    end

    def print_available_cops
      cops = Cop::Cop.all
      show_all = @options[:show_cops].empty?

      if show_all
        puts "# Available cops (#{cops.length}) + config for #{Dir.pwd}: "
      end

      cops.types.sort!.each { |type| print_cops_of_type(cops, type, show_all) }
    end

    def print_cops_of_type(cops, type, show_all)
      cops_of_this_type = cops.with_type(type).sort_by!(&:cop_name)

      if show_all
        puts "# Type '#{type.to_s.capitalize}' (#{cops_of_this_type.size}):"
      end

      selected_cops = cops_of_this_type.select do |cop|
        show_all || @options[:show_cops].include?(cop.cop_name)
      end

      selected_cops.each do |cop|
        puts '# Supports --auto-correct' if cop.new.support_autocorrect?
        puts "#{cop.cop_name}:"
        cnf = @config_store.for(Dir.pwd.to_s).for_cop(cop)
        puts cnf.to_yaml.lines.to_a[1..-1].map { |line| '  ' + line }
        puts
      end
    end

    def display_error_summary(errors)
      return if errors.empty?

      plural = errors.count > 1 ? 's' : ''
      warn "\n#{errors.count} error#{plural} occurred:".color(:red)

      errors.each { |error| warn error }

      warn <<-END.strip_indent
        Errors are usually caused by RuboCop bugs.
        Please, report your problems to RuboCop's issue tracker.
        Mention the following information in the issue report:
        #{RuboCop::Version.version(true)}
      END
    end
  end
end
