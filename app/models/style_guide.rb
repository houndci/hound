class StyleGuide
  def initialize(files)
    @files = files
  end

  def violations
    @violations ||= violator_files.map do |file|
      { filename: file.filename, violations: file.violations }
    end
  end

  private

  def violator_files
    @files.select { |file| file.violations.any? }
  end
end
