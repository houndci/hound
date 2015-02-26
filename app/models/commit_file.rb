class CommitFile
  pattr_initialize :file, :commit

  def filename
    file.filename
  end

  def content
    @content ||= begin
      unless removed?
        commit.file_content(filename)
      end
    end
  end

  def patch
    file.patch
  end

  def removed?
    file.status == "removed"
  end
end
