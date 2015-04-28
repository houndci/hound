module Language
  class ScssLocalLinter < LocalLinter
    def style_guide_name
      StyleGuide::Scss
    end
  end
end
