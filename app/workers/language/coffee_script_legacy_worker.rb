module Language
  class CoffeeScriptLegacyWorker < LegacyWorker
    private

    def style_guide_name
      StyleGuide::CoffeeScript
    end
  end
end
