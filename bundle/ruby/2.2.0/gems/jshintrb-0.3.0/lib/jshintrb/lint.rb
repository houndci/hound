# encoding: UTF-8

require "execjs"
require "multi_json"

module Jshintrb

  class Lint
    Error = ExecJS::Error

    # Default options for compilation
    DEFAULTS = {
      :bitwise => true,
      :curly => true,
      :eqeqeq => true,
      :forin => true,
      :immed => true,
      :latedef => true,
      :newcap => true,
      :noarg => true,
      :noempty => true,
      :nonew => true,
      :plusplus => true,
      :regexp => true,
      :undef => true,
      :strict => true,
      :trailing => true,
      :browser => true
    }

    SourcePath = File.expand_path("../../js/jshint.js", __FILE__)

    def initialize(options = nil, globals = nil)

      if options == :defaults then
        @options = DEFAULTS.dup
      elsif options == :jshintrc then
        raise '`.jshintrc` is not exist on current working directory.' unless File.exist?('./.jshintrc')
        @options = MultiJson.load(File.read('./.jshintrc'))
      elsif options.instance_of? Hash then
        @options = options.dup
        # @options = DEFAULTS.merge(options)
      elsif options.nil?
        @options = nil
      else
        raise 'Unsupported option for Jshintrb: ' + options.to_s
      end

      @globals = globals

      @context = ExecJS.compile("var window = {};\n" + File.open(SourcePath, "r:UTF-8").read)
    end

    def lint(source)
      source = source.respond_to?(:read) ? source.read : source.to_s

      js = []
      if @options.nil? and @globals.nil? then
        js << "JSHINT(#{MultiJson.dump(source)});"
      elsif @globals.nil? then
        js << "JSHINT(#{MultiJson.dump(source)}, #{MultiJson.dump(@options)});"
      else
        globals_hash = Hash[*@globals.product([false]).flatten]
        js << "JSHINT(#{MultiJson.dump(source)}, #{MultiJson.dump(@options)}, #{MultiJson.dump(globals_hash)});"
      end
      js << "return JSHINT.errors;"

      @context.exec js.join("\n")
    end

  end
end
