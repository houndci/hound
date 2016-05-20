# encoding: utf-8

require 'rake'
require 'rake/tasklib'

module RuboCop
  # Provides a custom rake task.
  #
  # require 'rubocop/rake_task'
  # RuboCop::RakeTask.new
  class RakeTask < Rake::TaskLib
    attr_accessor :name
    attr_accessor :verbose
    attr_accessor :fail_on_error
    attr_accessor :patterns
    attr_accessor :formatters
    attr_accessor :requires
    attr_accessor :options

    def initialize(*args, &task_block)
      setup_ivars(args)

      desc 'Run RuboCop' unless ::Rake.application.last_comment

      task(name, *args) do |_, task_args|
        RakeFileUtils.send(:verbose, verbose) do
          if task_block
            task_block.call(*[self, task_args].slice(0, task_block.arity))
          end
          run_main_task(verbose)
        end
      end

      setup_subtasks(name, *args, &task_block)
    end

    def run_main_task(verbose)
      run_cli(verbose, full_options)
    end

    private

    def run_cli(verbose, options)
      # We lazy-load rubocop so that the task doesn't dramatically impact the
      # load time of your Rakefile.
      require 'rubocop'

      cli = CLI.new
      puts 'Running RuboCop...' if verbose
      result = cli.run(options)
      abort('RuboCop failed!') if fail_on_error unless result == 0
    end

    def full_options
      [].tap do |result|
        result.concat(formatters.map { |f| ['--format', f] }.flatten)
        result.concat(requires.map { |r| ['--require', r] }.flatten)
        result.concat(options)
        result.concat(patterns)
      end
    end

    def setup_ivars(args)
      # More lazy-loading to keep load time down.
      require 'rubocop/options'

      @name = args.shift || :rubocop
      @verbose = true
      @fail_on_error = true
      @patterns = []
      @requires = []
      @options = []
      @formatters = [RuboCop::Options::DEFAULT_FORMATTER]
    end

    def setup_subtasks(name, *args, &task_block)
      namespace name do
        desc 'Auto-correct RuboCop offenses'

        task(:auto_correct, *args) do |_, task_args|
          if task_block
            task_block.call(*[self, task_args].slice(0, task_block.arity))
          end
          options = full_options.unshift('--auto-correct')
          run_cli(verbose, options)
        end
      end
    end
  end
end
