module Language
  class JavaScriptLocalLinter < LocalLinter
    private

    def style_guide_name
      StyleGuide::JavaScript
    end
  end
end
