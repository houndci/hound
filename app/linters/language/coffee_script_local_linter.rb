module Language
  class CoffeeScriptLocalLinter < LocalLinter
    def style_guide_name
      StyleGuide::CoffeeScript
    end
  end
end
