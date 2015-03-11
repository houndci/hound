class CommitFile
  def initialize(attributes)
    @attributes = attributes
  end

  def commit
    @attributes.fetch(:commit)
  end

  def filename
    @attributes.fetch(:filename)
  end

  def repo_name
    commit.repo_name
  end

  def sha
    commit.sha
  end

  def content
    @content ||= begin
      unless removed?
        commit.file_content(filename)
      end
    end
  end

  def removed?
    @attributes.fetch(:status) == "removed"
  end

  def line_at(line_number)
    changed_lines.detect { |line| line.number == line_number } ||
      UnchangedLine.new
  end

  def patch_body
    @attributes.fetch(:patch)
  end

  private

  def changed_lines
    @changed_lines ||= patch.changed_lines
  end

  def patch
    Patch.new(patch_body)
  end
end
