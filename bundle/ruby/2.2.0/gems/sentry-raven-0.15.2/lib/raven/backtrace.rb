## Inspired by Rails' and Airbrake's backtrace parsers.

module Raven

  # Front end to parsing the backtrace for each notice
  class Backtrace

    # Handles backtrace parsing line by line
    class Line

      # regexp (optionnally allowing leading X: for windows support)
      RUBY_INPUT_FORMAT = %r{^((?:[a-zA-Z]:)?[^:]+|<.*>):(\d+)(?::in `([^']+)')?$}.freeze

      # org.jruby.runtime.callsite.CachingCallSite.call(CachingCallSite.java:170)
      JAVA_INPUT_FORMAT = %r{^(.+)\.([^\.]+)\(([^\:]+)\:(\d+)\)$}.freeze

      APP_DIRS_PATTERN = /(bin|app|config|lib|test)/

      # The file portion of the line (such as app/models/user.rb)
      attr_reader :file

      # The line number portion of the line
      attr_reader :number

      # The method of the line (such as index)
      attr_reader :method

      # The module name (JRuby)
      attr_reader :module_name

      # Parses a single line of a given backtrace
      # @param [String] unparsed_line The raw line from +caller+ or some backtrace
      # @return [Line] The parsed backtrace line
      def self.parse(unparsed_line)
        ruby_match = unparsed_line.match(RUBY_INPUT_FORMAT)
        if ruby_match
          _, file, number, method = ruby_match.to_a
          module_name = nil
        else
          java_match = unparsed_line.match(JAVA_INPUT_FORMAT)
          _, module_name, method, file, number = java_match.to_a
        end
        new(file, number, method, module_name)
      end

      def initialize(file, number, method, module_name)
        self.file = file
        self.module_name = module_name
        self.number = number.to_i
        self.method = method
      end

      def in_app
        app_dirs = Raven.configuration.app_dirs_pattern || APP_DIRS_PATTERN
        @in_app_pattern ||= Regexp.new("^(#{project_root}/)?#{app_dirs}")

        if self.file =~ @in_app_pattern
          true
        else
          false
        end
      end

      def project_root
        @project_root ||= Raven.configuration.project_root && Raven.configuration.project_root.to_s
      end

      # Reconstructs the line in a readable fashion
      def to_s
        "#{file}:#{number}:in `#{method}'"
      end

      def ==(other)
        to_s == other.to_s
      end

      def inspect
        "<Line:#{self}>"
      end

      private

      attr_writer :file, :number, :method, :module_name
    end

    # holder for an Array of Backtrace::Line instances
    attr_reader :lines

    def self.parse(ruby_backtrace, opts = {})
      ruby_lines = split_multiline_backtrace(ruby_backtrace)

      filters = opts[:filters] || []
      filtered_lines = ruby_lines.to_a.map do |line|
        filters.reduce(line) do |nested_line, proc|
          proc.call(nested_line)
        end
      end.compact

      lines = filtered_lines.map do |unparsed_line|
        Line.parse(unparsed_line)
      end

      new(lines)
    end

    def initialize(lines)
      self.lines = lines
    end

    def inspect
      "<Backtrace: " + lines.map { |line| line.inspect }.join(", ") + ">"
    end

    def to_s
      content = []
      lines.each do |line|
        content << line
      end
      content.join("\n")
    end

    def ==(other)
      if other.respond_to?(:lines)
        lines == other.lines
      else
        false
      end
    end

    private

    attr_writer :lines

    def self.split_multiline_backtrace(backtrace)
      if backtrace.to_a.size == 1
        backtrace.to_a.first.split(/\n\s*/)
      else
        backtrace
      end
    end
  end
end
