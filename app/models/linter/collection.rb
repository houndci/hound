module Linter
  class Collection
    LINTERS = [
      Linter::CoffeeLint,
      Linter::Eslint,
      Linter::GoLint,
      Linter::HamlLint,
      Linter::Jscs,
      Linter::Jshint,
      Linter::Remark,
      Linter::Flake8,
      Linter::Rubocop,
      Linter::ScssLint,
      Linter::SwiftLint,
    ].freeze

    def self.linter_names
      LINTERS.map { |klass| klass.name.demodulize.underscore }
    end

    def self.for(filename:, **linter_args)
      linter_classes = LINTERS.
        select { |linter_class| linter_class.can_lint?(filename) }.
        map { |linter_class| linter_class.new(**linter_args) }

      new(linter_classes.presence || default_linter(**linter_args))
    end

    attr_reader :linters

    def initialize(linters = [])
      @linters = Array(linters)
    end

    def file_review(commit_file)
      linters.
        select(&:enabled?).
        select { |linter| linter.file_included?(commit_file) }.
        each { |linter| linter.file_review(commit_file) }
    end

    def self.default_linter(**linter_args)
      Linter::Unsupported.new(**linter_args)
    end
    private_class_method :default_linter
  end
end
