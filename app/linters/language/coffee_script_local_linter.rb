module Language
  class CoffeeScriptLocalLinter < LocalLinter
    private

    def style_guide_name
      StyleGuide::CoffeeScript
    end
  end
end
