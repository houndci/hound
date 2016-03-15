module Linter
  class Cane < Base
    FILE_REGEXP = /.+\.rb\z/

    def file_review(commit_file)
      perform_file_review(commit_file)
    end

    private

    def perform_file_review(commit_file)
      tmp_file = Tempfile.new("canefile")
      begin
        tmp_file.write(commit_file.content)
        tmp_file.close
        run_cane(tmp_file, commit_file)
      ensure
        tmp_file.close
        tmp_file.unlink
      end
    end

    def run_cane(tmp_file, commit_file)
      FileReview.create!(filename: commit_file.filename) do |file_review|
        inspect_file(tmp_file.path).each do |violation|
          line = commit_file.line_at(violation[:line])
          file_review.build_violation(line, violation_text(violation))
        end

        file_review.build = build
        file_review.complete
      end
    end

    def violation_text(violation)
      violation[:label] || violation[:description]
    end

    def inspect_file(file_name)
      opts = options.merge(
        abc_glob: file_name,
        style_glob: file_name,
        doc_glob: file_name,
      )

      ::Cane::Runner.new(opts).send(:violations)
    end

    def options
      @options ||= default_options
    end

    def default_options
      opts = ::Cane::CLI.default_options
      canefile = ::Cane::CLI::Parser.new
      canefile.parser.parse!(config.content)
      opts.merge! canefile.options
    end
  end
end
