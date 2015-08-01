module StyleGuide
  class Go < Base
    LANGUAGE = "go"

    def file_included?(commit_file)
      !vendored?(commit_file.filename)
    end

    private

    def vendored?(filename)
      path_components = Pathname(filename).each_filename

      path_components.include?("vendor") ||
        path_components.take(2) == ["Godeps", "_workspace"]
    end
  end
end
