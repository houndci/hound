module Language
  class ScssLocalLinter < LocalLinter
    private

    def style_guide_name
      StyleGuide::Scss
    end
  end
end
