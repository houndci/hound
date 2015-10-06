require 'optparse'
require 'fileutils'
require 'rbconfig'

module Html2haml
  # This module handles the Html2haml executable.
  module Exec
    # An abstract class that encapsulates the executable code for the Html2haml executable.
    # It's split into a base class and a subclass for historic reasons: this previously
    # was used by all the executables in the Haml project, before Html2haml was moved
    # into its own gem.
    class Generic
      # @param args [Array<String>] The command-line arguments
      def initialize(args)
        @args = args
        @options = {:for_engine => {}}
      end

      # Parses the command-line arguments and runs the executable.
      # Calls `Kernel#exit` at the end, so it never returns.
      #
      # @see #parse
      def parse!
        begin
          parse
        rescue Exception => e
          raise e if @options[:trace] || e.is_a?(SystemExit)

          $stderr.print "#{e.class}: " unless e.class == RuntimeError
          $stderr.puts "#{e.message}"
          $stderr.puts "  Use --trace for backtrace."
          exit 1
        end
        exit 0
      end

      # Parses the command-line arguments and runs the executable.
      # This does not handle exceptions or exit the program.
      #
      # @see #parse!
      def parse
        @opts = OptionParser.new(&method(:set_opts))
        @opts.parse!(@args)

        process_result

        @options
      end

      # @return [String] A description of the executable
      def to_s
        @opts.to_s
      end

      protected

      # Finds the line of the source template
      # on which an exception was raised.
      #
      # @param exception [Exception] The exception
      # @return [String] The line number
      def get_line(exception)
        # SyntaxErrors have weird line reporting
        # when there's trailing whitespace,
        # which there is for Haml documents.
        return (exception.message.scan(/:(\d+)/).first || ["??"]).first if exception.is_a?(::SyntaxError)
        (exception.backtrace[0].scan(/:(\d+)/).first || ["??"]).first
      end

      # Tells optparse how to parse the arguments
      # available for all executables.
      #
      # This is meant to be overridden by subclasses
      # so they can add their own options.
      #
      # @param opts [OptionParser]
      def set_opts(opts)
        opts.on('-s', '--stdin', :NONE, 'Read input from standard input instead of an input file') do
          @options[:input] = $stdin
        end

        opts.on('--trace', :NONE, 'Show a full traceback on error') do
          @options[:trace] = true
        end

        opts.on('--unix-newlines', 'Use Unix-style newlines in written files.') do
          # Note that this is the preferred way to check for Windows, since
          # JRuby and Rubinius also run there.
          if RbConfig::CONFIG['host_os'] =~ /mswin|windows|mingw/i
            @options[:unix_newlines] = true
          end
        end

        opts.on_tail("-?", "-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on_tail("-v", "--version", "Print version") do
          puts("html2haml #{::Html2haml::VERSION}")
          exit
        end
      end

      # Processes the options set by the command-line arguments.
      # In particular, sets `@options[:input]` and `@options[:output]`
      # to appropriate IO streams.
      #
      # This is meant to be overridden by subclasses
      # so they can run their respective programs.
      def process_result
        input, output = @options[:input], @options[:output]
        args = @args.dup
        input ||=
          begin
            filename = args.shift
            @options[:filename] = filename
            open_file(filename) || $stdin
          end
        output ||= open_file(args.shift, 'w') || $stdout

        @options[:input], @options[:output] = input, output
      end

      COLORS = { :red => 31, :green => 32, :yellow => 33 }

      # Prints a status message about performing the given action,
      # colored using the given color (via terminal escapes) if possible.
      #
      # @param name [#to_s] A short name for the action being performed.
      #   Shouldn't be longer than 11 characters.
      # @param color [Symbol] The name of the color to use for this action.
      #   Can be `:red`, `:green`, or `:yellow`.
      def puts_action(name, color, arg)
        return if @options[:for_engine][:quiet]
        printf color(color, "%11s %s\n"), name, arg
      end

      # Same as `Kernel.puts`, but doesn't print anything if the `--quiet` option is set.
      #
      # @param args [Array] Passed on to `Kernel.puts`
      def puts(*args)
        return if @options[:for_engine][:quiet]
        Kernel.puts(*args)
      end

      # Wraps the given string in terminal escapes
      # causing it to have the given color.
      # If terminal esapes aren't supported on this platform,
      # just returns the string instead.
      #
      # @param color [Symbol] The name of the color to use.
      #   Can be `:red`, `:green`, or `:yellow`.
      # @param str [String] The string to wrap in the given color.
      # @return [String] The wrapped string.
      def color(color, str)
        raise "[BUG] Unrecognized color #{color}" unless COLORS[color]

        # Almost any real Unix terminal will support color,
        # so we just filter for Windows terms (which don't set TERM)
        # and not-real terminals, which aren't ttys.
        return str if ENV["TERM"].nil? || ENV["TERM"].empty? || !STDOUT.tty?
        return "\e[#{COLORS[color]}m#{str}\e[0m"
      end

      private

      def open_file(filename, flag = 'r')
        return if filename.nil?
        flag = 'wb' if @options[:unix_newlines] && flag == 'w'
        File.open(filename, flag)
      end

      def handle_load_error(err)
        dep = err.message[/^no such file to load -- (.*)/, 1]
        raise err if @options[:trace] || dep.nil? || dep.empty?
        $stderr.puts <<MESSAGE
Required dependency #{dep} not found!
    Run "gem install #{dep}" to get it.
  Use --trace for backtrace.
MESSAGE
        exit 1
      end
    end

    # The `html2haml` executable.
    class HTML2Haml < Generic
      # @param args [Array<String>] The command-line arguments
      def initialize(args)
        super
        @module_opts = {}
      end

      # Tells optparse how to parse the arguments.
      #
      # @param opts [OptionParser]
      def set_opts(opts)
        opts.banner = <<END
Usage: html2haml [options] [INPUT] [OUTPUT]

Description: Transforms an HTML file into corresponding Haml code.

Options:
END

        opts.on('-e', '--erb', 'Parse ERb tags.') do
          @module_opts[:erb] = true
        end

        opts.on('--no-erb', "Don't parse ERb tags.") do
          @options[:no_erb] = true
        end

        opts.on("--html-attributes", "Use HTML style attributes instead of Ruby hash style.") do
          @module_opts[:html_style_attributes] = true
        end

        opts.on("--ruby19-attributes", "Use Ruby 1.9-style attributes when possible.") do
          @module_opts[:ruby19_style_attributes] = true
        end

        opts.on('-E ex[:in]', 'Specify the default external and internal character encodings.') do |encoding|
          external, internal = encoding.split(':')
          Encoding.default_external = external if external && !external.empty?
          Encoding.default_internal = internal if internal && !internal.empty?
        end

        super
      end

      # Processes the options set by the command-line arguments,
      # and runs the HTML compiler appropriately.
      def process_result
        super

        require 'html2haml/html'

        input = @options[:input]
        output = @options[:output]

        @module_opts[:erb] ||= input.respond_to?(:path) && input.path =~ /\.(rhtml|erb)$/
        @module_opts[:erb] &&= @options[:no_erb] != false

        output.write(HTML.new(input, @module_opts).render)
      rescue ::Haml::Error => e
        raise "#{e.is_a?(::Haml::SyntaxError) ? "Syntax error" : "Error"} on line " +
          "#{get_line e}: #{e.message}"
      rescue LoadError => err
        handle_load_error(err)
      end
    end
  end
end
