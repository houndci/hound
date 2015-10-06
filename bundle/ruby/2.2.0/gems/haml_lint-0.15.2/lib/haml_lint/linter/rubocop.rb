require 'haml_lint/ruby_extractor'
require 'rubocop'
require 'tempfile'

module HamlLint
  # Runs RuboCop on Ruby code contained within HAML templates.
  class Linter::RuboCop < Linter
    include LinterRegistry

    def visit_root(_node)
      extractor = HamlLint::RubyExtractor.new
      extracted_source = extractor.extract(document)

      return if extracted_source.source.empty?

      find_lints(extracted_source.source, extracted_source.source_map)
    end

    private

    # Executes RuboCop against the given Ruby code and records the offenses as
    # lints.
    #
    # @param ruby [String] Ruby code
    # @param source_map [Hash] map of Ruby code line numbers to original line
    #   numbers in the template
    def find_lints(ruby, source_map)
      rubocop = ::RuboCop::CLI.new

      original_filename = document.file || 'ruby_script'
      filename = "#{File.basename(original_filename)}.haml_lint.tmp"
      directory = File.dirname(original_filename)

      Tempfile.open(filename, directory) do |f|
        begin
          f.write(ruby)
          f.close
          extract_lints_from_offenses(lint_file(rubocop, f.path), source_map)
        ensure
          f.unlink
        end
      end
    end

    # Defined so we can stub the results in tests
    #
    # @param rubocop [RuboCop::CLI]
    # @param file [String]
    # @return [Array<RuboCop::Cop::Offense>]
    def lint_file(rubocop, file)
      rubocop.run(rubocop_flags << file)
      OffenseCollector.offenses
    end

    # Aggregates RuboCop offenses and converts them to {HamlLint::Lint}s
    # suitable for reporting.
    #
    # @param offenses [Array<RuboCop::Cop::Offense>]
    # @param source_map [Hash]
    def extract_lints_from_offenses(offenses, source_map)
      dummy_node = Struct.new(:line)

      offenses.select { |offense| !config['ignored_cops'].include?(offense.cop_name) }
              .each do |offense|
        record_lint(dummy_node.new(source_map[offense.line]), offense.message)
      end
    end

    # Returns flags that will be passed to RuboCop CLI.
    #
    # @return [Array<String>]
    def rubocop_flags
      flags = %w[--format HamlLint::OffenseCollector]
      flags += ['--config', ENV['HAML_LINT_RUBOCOP_CONF']] if ENV['HAML_LINT_RUBOCOP_CONF']
      flags
    end
  end

  # Collects offenses detected by RuboCop.
  class OffenseCollector < ::RuboCop::Formatter::BaseFormatter
    class << self
      # List of offenses reported by RuboCop.
      attr_accessor :offenses
    end

    # Executed when RuboCop begins linting.
    #
    # @param _target_files [Array<String>]
    def started(_target_files)
      self.class.offenses = []
    end

    # Executed when a file has been scanned by RuboCop, adding the reported
    # offenses to our collection.
    #
    # @param _file [String]
    # @param offenses [Array<RuboCop::Cop::Offense>]
    def file_finished(_file, offenses)
      self.class.offenses += offenses
    end
  end
end
