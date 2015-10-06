# encoding: UTF-8

require "jshintrb/version"
require "jshintrb/lint"
require "jshintrb/reporter/default"

module Jshintrb

  def self.lint(source, options = nil, globals = nil)
    Lint.new(options, globals).lint(source)
  end

  def self.report(source, options = nil, globals = nil, out = nil)
    reporter = Reporter::Default.new
    linter = Lint.new(options, globals)
    report = ''
    if source.is_a?(Array) then
      source.each do |src|
        if !src.is_a?(String) then
          p src.to_s
          raise ArgumentError, 'Expected array of strings. Instead get ' + src.class.to_s
        end
        errors = linter.lint(File.read(src))
        rep = reporter.format errors, src
        if out && rep.size > 0 then
          out.puts rep
        end
        report += rep
      end
    else
      errors = linter.lint(source)
      report = reporter.format errors
      if out then
        out.puts report
      end
    end
    report
  end

end
