require 'raven/interfaces'

module Raven
  class StacktraceInterface < Interface

    name 'stacktrace'
    attr_accessor :frames

    def initialize(*arguments)
      self.frames = []
      super(*arguments)
    end

    def to_hash(*args)
      data = super(*args)
      data[:frames] = data[:frames].map { |frame| frame.to_hash }
      data
    end

    # Not actually an interface, but I want to use the same style
    class Frame < Interface
      attr_accessor :abs_path
      attr_accessor :function
      attr_accessor :vars
      attr_accessor :pre_context
      attr_accessor :post_context
      attr_accessor :context_line
      attr_accessor :module
      attr_accessor :lineno
      attr_accessor :in_app

      def initialize(*arguments)
        self.vars, self.pre_context, self.post_context = [], [], []
        super(*arguments)
      end

      def filename
        return nil if self.abs_path.nil?

        prefix = if under_project_root? && in_app
          project_root
        elsif under_project_root?
          longest_load_path || project_root
        else
          longest_load_path
        end

        prefix ? self.abs_path[prefix.to_s.chomp(File::SEPARATOR).length+1..-1] : self.abs_path
      end

      def under_project_root?
        project_root && abs_path.start_with?(project_root)
      end

      def project_root
        @project_root ||= Raven.configuration.project_root && Raven.configuration.project_root.to_s
      end

      def longest_load_path
        $LOAD_PATH.select { |s| self.abs_path.start_with?(s.to_s) }.sort_by { |s| s.to_s.length }.last
      end

      def to_hash(*args)
        data = super(*args)
        data[:filename] = self.filename
        data.delete(:vars) unless self.vars && !self.vars.empty?
        data.delete(:pre_context) unless self.pre_context && !self.pre_context.empty?
        data.delete(:post_context) unless self.post_context && !self.post_context.empty?
        data.delete(:context_line) unless self.context_line && !self.context_line.empty?
        data
      end
    end
  end

  register_interface :stack_trace => StacktraceInterface
end
