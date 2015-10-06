require "coffeelint/version"
require 'coffeelint/config'
require 'coffeelint/cmd'
require 'execjs'
require 'coffee-script'

module Coffeelint
  require 'coffeelint/railtie' if defined?(Rails::Railtie)

  def self.set_path(custom_path)
    @path = custom_path
  end

  def self.path()
    @path ||= File.expand_path('../../coffeelint/lib/coffeelint.js', __FILE__)
  end

  def self.colorize(str, color_code)
    "\e[#{color_code}m#{str}\e[0m"
  end

  def self.red(str, pretty_output = true)
    pretty_output ? Coffeelint.colorize(str, 31) : str
  end

  def self.green(str, pretty_output = true)
    pretty_output ? Coffeelint.colorize(str, 32) : str
  end

  def self.yellow(str, pretty_output = true)
    pretty_output ? Coffeelint.colorize(str, 33) : str
  end

  def self.context
    coffeescriptSource = File.read(CoffeeScript::Source.path)
    bootstrap = <<-EOF
    window = {
      CoffeeScript: CoffeeScript,
      coffeelint: {}
    };
    EOF
    coffeelintSource = File.read(Coffeelint.path)
    ExecJS.compile(coffeescriptSource + bootstrap + coffeelintSource)
  end

  def self.lint(script, config = {})
    fname = config.fetch(:config_file, CoffeeLint::Config.locate)
    config.merge!(CoffeeLint::Config.parse(fname)) unless fname.nil?
    Coffeelint.context.call('window.coffeelint.lint', script, config)
  end

  def self.lint_file(filename, config = {})
    Coffeelint.lint(File.read(filename), config)
  end

  def self.lint_dir(directory, config = {})
    retval = {}
    Dir.glob("#{directory}/**/*.coffee") do |name|
      retval[name] = Coffeelint.lint_file(name, config)
      yield name, retval[name] if block_given?
    end
    retval
  end

  def self.display_test_results(name, errors, pretty_output = true)
    good = pretty_output ? "\u2713" : 'Passed'
    warn = pretty_output ? "\u26A1" : 'Warn'
    bad = pretty_output ? "\u2717" : 'Failed'

    if errors.length == 0
      puts "  #{good} " + Coffeelint.green(name, pretty_output)
      return true
    else
      no_failures = true
      if errors.any? {|e| e["level"] == "error"}
        no_failures = false
        puts "  #{bad} " + Coffeelint.red(name, pretty_output)
      else
        puts "  #{warn} " + Coffeelint.yellow(name, pretty_output)
      end

      errors.each do |error|
        disp = "##{error["lineNumber"]}"
        if error["lineNumberEnd"]
          disp += "-#{error["lineNumberEnd"]}"
        end

        print "     "
        if error["level"] == "warn"
          print warn + " "
          print Coffeelint.yellow(disp, pretty_output)
        else
          print bad + " "
          print Coffeelint.red(disp, pretty_output)
        end
        puts ": #{error["message"]}. #{error["context"]}."
      end
      return no_failures
    end
  end

  def self.run_test(file, config = {})
    pretty_output = config.has_key?(:pretty_output) ? config.delete(:pretty_output) : true
    result = Coffeelint.lint_file(file, config)
    Coffeelint.display_test_results(file, result, pretty_output)
  end

  def self.run_test_suite(directory, config = {})
    pretty_output = config.has_key?(:pretty_output) ? config.delete(:pretty_output) : true
    errors_count = 0
    Coffeelint.lint_dir(directory, config) do |name, errors|
      errors_count += errors.count
      result = Coffeelint.display_test_results(name, errors, pretty_output)
    end
    errors_count
  end
end
