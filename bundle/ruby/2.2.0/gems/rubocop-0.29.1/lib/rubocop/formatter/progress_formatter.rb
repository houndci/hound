# encoding: utf-8

module RuboCop
  module Formatter
    # This formatter display dots for files with no offenses and
    # letters for files with problems in the them. In the end it
    # appends the regular report data in the clang style format.
    class ProgressFormatter < ClangStyleFormatter
      def started(target_files)
        super
        @offenses_for_files = {}
        file_phrase = target_files.count == 1 ? 'file' : 'files'
        output.puts "Inspecting #{target_files.count} #{file_phrase}"
      end

      def file_finished(file, offenses)
        unless offenses.empty?
          count_stats(offenses)
          @offenses_for_files[file] = offenses
        end

        report_file_as_mark(offenses)
      end

      def finished(inspected_files)
        output.puts

        unless @offenses_for_files.empty?
          output.puts
          output.puts 'Offenses:'
          output.puts

          @offenses_for_files.each do |file, offenses|
            report_file(file, offenses)
          end
        end

        report_summary(inspected_files.count,
                       @total_offense_count,
                       @total_correction_count)
      end

      def report_file_as_mark(offenses)
        mark = if offenses.empty?
                 green('.')
               else
                 highest_offense = offenses.max_by(&:severity)
                 colored_severity_code(highest_offense)
               end

        output.write mark
      end
    end
  end
end
