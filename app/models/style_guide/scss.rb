module StyleGuide
  class Scss < Base
    LANGUAGE = "scss"

    def file_included?(_)
      true
    end
  end
end
