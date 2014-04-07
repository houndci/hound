class FileCollection
  IGNORED_FILES = ['db/schema.rb']

  attr_reader :files

  def initialize(files)
    @files = files
  end

  def relevant_files
    files.reject do |file|
      file.removed? || file.renamed? || !file.ruby? ||
        IGNORED_FILES.include?(file.filename)
    end
  end
end
